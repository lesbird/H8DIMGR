using System.IO.Ports;

namespace H8DImgHost;

public class ProtocolException(string message) : Exception(message);

// Talks to H8DIMGR4 running on the Heathkit over the 340Q serial port.
//
// Protocol summary (see CMDL in H8DIMGR4.ASM):
//   '0' / '1'      select SY0: / SY1:                 -> echo
//   '4'..'7'       set disk type 1S40/2S40/1S80/2S80  -> echo
//   'V' vol        set volume number                  -> echo
//   'A' / 'B'      no-op                              -> echo
//   'C'            HDOS label volume (trk 0 byte 900H)-> vol, 'C'
//   'Q'            query disk type                    -> 'Q', type (FF = error)
//   'R'            read image; then per track:
//                    host 'R' -> 2560 bytes, 'R'
//   'W'            write image; then per track:
//                    host 'W' + 2560 bytes -> 'W' (or '?' on disk error)
//   anything else                                     -> '?'
public sealed class H8Client : IDisposable
{
    const int CommandTimeoutMs = 5000;
    const int DiskTimeoutMs = 20000;    // track read, query, format+write
    const byte AbortByte = (byte)'A';   // any byte other than 'R'/'W' mid-transfer

    readonly SerialPort port;

    public string PortName => port.PortName;

    // Serial port names worth offering. On macOS only the call-out (cu.*)
    // devices are useful; tty.* blocks waiting for carrier detect.
    public static string[] AvailablePorts()
    {
        var ports = SerialPort.GetPortNames();
        if (OperatingSystem.IsMacOS())
        {
            ports = ports.Where(p => !p.StartsWith("/dev/tty.")).ToArray();
        }
        Array.Sort(ports, StringComparer.OrdinalIgnoreCase);
        return ports;
    }

    public H8Client(string portName, int baud)
    {
        port = new SerialPort(portName, baud, Parity.None, 8, StopBits.Two)
        {
            Handshake = Handshake.None,
            ReadTimeout = CommandTimeoutMs,
            WriteTimeout = DiskTimeoutMs,
            ReadBufferSize = 64 * 1024,
            WriteBufferSize = 8 * 1024,
        };
        port.Open();
        port.DiscardInBuffer();
        port.DiscardOutBuffer();
    }

    public void Dispose() => port.Dispose();

    // Confirms the client is at its command loop. If it was left waiting inside
    // RDIMG/WRIMG by an interrupted session, the first non-'R'/'W' byte bounces
    // it back to CMD, so retry a few times.
    public void Probe()
    {
        for (int attempt = 0; attempt < 3; attempt++)
        {
            port.DiscardInBuffer();
            Send((byte)'A');
            try
            {
                if (ReadByte(1500) == 'A')
                {
                    return;
                }
            }
            catch (TimeoutException)
            {
            }
            Thread.Sleep(250);
        }
        throw new ProtocolException("No response from H8DIMGR4. Is it running and is the cable on port 340Q?");
    }

    public void SelectDrive(int drive)
    {
        if (drive is < 0 or > 1)
        {
            throw new ArgumentOutOfRangeException(nameof(drive));
        }
        Echo((byte)('0' + drive));
    }

    public void SetType(DiskType type) => Echo(DiskTypes.Command(type));

    public void SetVolume(byte volume)
    {
        Send((byte)'V', volume);
        Expect((byte)'V', CommandTimeoutMs);
    }

    // Returns the detected type, or null if the client could not identify the
    // disk. Also loads the client's HDRVOL from the track 4 sector header,
    // which RDIMG uses for tracks 1 and up.
    public DiskType? Query()
    {
        Send((byte)'Q');
        Expect((byte)'Q', CommandTimeoutMs);
        byte t = ReadByte(DiskTimeoutMs);
        return t <= 3 ? (DiskType)t : null;
    }

    // Volume number from the HDOS label (sector 9 of track 0). Only meaningful
    // for HDOS disks.
    public byte GetHdosVolume()
    {
        Send((byte)'C');
        byte vol = ReadByte(DiskTimeoutMs);
        Expect((byte)'C', CommandTimeoutMs);
        return vol;
    }

    // Detects the disk and applies any overrides, leaving the client ready for
    // ReadImage. Query always runs: besides detecting the type it loads the
    // client's header volume, which it uses when reading tracks 1 and up.
    public DiskType PrepareRead(DiskType? typeOverride, byte? volumeOverride, Action<string>? log = null)
    {
        var detected = Query();
        log?.Invoke($"Detected: {(detected is null ? "unknown" : DiskTypes.Name(detected.Value))}");

        var type = typeOverride ?? detected
            ?? throw new ProtocolException("Could not detect disk type. Specify the type and volume.");
        if (typeOverride is not null)
        {
            SetType(type);
        }

        if (volumeOverride is not null)
        {
            SetVolume(volumeOverride.Value);
        }
        else if (detected is null)
        {
            log?.Invoke("Warning: no volume from the disk header, using volume 0");
            SetVolume(0);
        }
        return type;
    }

    public byte[] ReadImage(DiskType type, Action<int, int>? progress = null, CancellationToken cancel = default)
    {
        int tracks = DiskTypes.Tracks(type);
        var image = new byte[tracks * DiskTypes.TrackSize];

        Send((byte)'R');
        for (int t = 0; t < tracks; t++)
        {
            if (cancel.IsCancellationRequested)
            {
                // RDIMG1 treats anything but 'R' as abort and answers 'R'
                Send(AbortByte);
                TryDrain();
                cancel.ThrowIfCancellationRequested();
            }
            Send((byte)'R');
            ReadExact(image, t * DiskTypes.TrackSize, DiskTypes.TrackSize, DiskTimeoutMs);
            Expect((byte)'R', CommandTimeoutMs);
            progress?.Invoke(t, tracks);
        }
        return image;
    }

    // startDelayMs: after the 'W' command the client seeks and syncs to the
    // index hole before it polls for the first track. The 8250 has no FIFO, so
    // track data sent before then would overrun.
    public void WriteImage(DiskType type, byte[] image, int startDelayMs, Action<int, int>? progress = null,
        CancellationToken cancel = default)
    {
        int tracks = DiskTypes.Tracks(type);
        if (image.Length != tracks * DiskTypes.TrackSize)
        {
            throw new ArgumentException($"Image is {image.Length} bytes, expected {tracks * DiskTypes.TrackSize} for {DiskTypes.Name(type)}");
        }

        Send((byte)'W');
        cancel.WaitHandle.WaitOne(startDelayMs);

        var packet = new byte[DiskTypes.TrackSize + 1];
        packet[0] = (byte)'W';
        for (int t = 0; t < tracks; t++)
        {
            if (cancel.IsCancellationRequested)
            {
                // WRIMGL treats anything but 'W' as abort (no reply)
                Send(AbortByte);
                TryDrain();
                cancel.ThrowIfCancellationRequested();
            }
            Buffer.BlockCopy(image, t * DiskTypes.TrackSize, packet, 1, DiskTypes.TrackSize);
            port.Write(packet, 0, packet.Length);

            byte reply = ReadByte(DiskTimeoutMs);
            if (reply == '?')
            {
                throw new ProtocolException($"Disk write error on track {t}. Is the disk write protected?");
            }
            if (reply != 'W')
            {
                throw new ProtocolException($"Unexpected reply 0x{reply:X2} after track {t}");
            }
            progress?.Invoke(t, tracks);
        }
    }

    // Discards whatever the client sends while it unwinds back to CMD
    void TryDrain()
    {
        Thread.Sleep(500);
        port.DiscardInBuffer();
    }

    void Echo(byte cmd)
    {
        Send(cmd);
        Expect(cmd, CommandTimeoutMs);
    }

    void Send(params byte[] data) => port.Write(data, 0, data.Length);

    void Expect(byte expected, int timeoutMs)
    {
        byte b = ReadByte(timeoutMs);
        if (b != expected)
        {
            throw new ProtocolException($"Expected '{(char)expected}' but got 0x{b:X2}");
        }
    }

    byte ReadByte(int timeoutMs)
    {
        port.ReadTimeout = timeoutMs;
        int b = port.ReadByte();
        if (b < 0)
        {
            throw new ProtocolException("Serial port closed");
        }
        return (byte)b;
    }

    void ReadExact(byte[] buf, int offset, int count, int timeoutMs)
    {
        port.ReadTimeout = timeoutMs;
        while (count > 0)
        {
            int n = port.Read(buf, offset, count);
            offset += n;
            count -= n;
        }
    }
}
