using H8DImgHost;

if (args.Length == 0 || args[0] is "-h" or "--help" or "help")
{
    Usage();
    return 0;
}

try
{
    var verb = args[0].ToLowerInvariant();
    if (verb == "ports")
    {
        foreach (var p in H8Client.AvailablePorts())
        {
            Console.WriteLine(p);
        }
        return 0;
    }

    var opts = Options.Parse(args.Skip(1).ToArray());
    return verb switch
    {
        "query" => Query(opts),
        "read" => Read(opts),
        "write" => Write(opts),
        _ => throw new UsageException($"Unknown command '{args[0]}'"),
    };
}
catch (UsageException ex)
{
    Console.Error.WriteLine($"error: {ex.Message}");
    Console.Error.WriteLine();
    Usage();
    return 2;
}
catch (OperationCanceledException)
{
    Console.Error.WriteLine();
    Console.Error.WriteLine("Cancelled.");
    return 130;
}
catch (Exception ex) when (ex is ProtocolException or TimeoutException or IOException or UnauthorizedAccessException)
{
    Console.Error.WriteLine();
    Console.Error.WriteLine($"error: {ex.Message}");
    return 1;
}

static int Query(Options o)
{
    using var client = Connect(o);
    var type = client.Query();
    if (type is null)
    {
        Console.WriteLine("Disk type: could not be determined");
        return 1;
    }
    Console.WriteLine($"Disk type: {DiskTypes.Name(type.Value)}");
    Console.WriteLine($"HDOS label volume: {client.GetHdosVolume()} (meaningful for HDOS disks only)");
    return 0;
}

static int Read(Options o)
{
    var file = o.File ?? throw new UsageException("read requires an output file");
    if (File.Exists(file) && !o.Force)
    {
        throw new UsageException($"{file} exists (use --force to overwrite)");
    }

    using var client = Connect(o);
    var type = client.PrepareRead(o.Type, o.Volume, Console.WriteLine);

    Console.WriteLine($"Reading {DiskTypes.Name(type)} from SY{o.Drive}: to {file}");
    var image = client.ReadImage(type, Progress, CancelOnCtrlC());
    File.WriteAllBytes(file, image);
    Console.WriteLine($"Done. Wrote {image.Length} bytes.");
    return 0;
}

static int Write(Options o)
{
    var file = o.File ?? throw new UsageException("write requires an image file");
    var image = File.ReadAllBytes(file);

    var type = o.Type ?? DiskTypes.FromImageSize(image.Length, o.Drive)
        ?? throw new UsageException($"Can't infer disk type from image size {image.Length}. Use --type.");
    if (image.Length != DiskTypes.ImageSize(type))
    {
        throw new UsageException($"Image is {image.Length} bytes but {DiskTypes.Name(type)} needs {DiskTypes.ImageSize(type)}");
    }

    byte volume = o.Volume ?? DiskTypes.HdosLabelVolume(image) ?? 0;
    Console.WriteLine($"Writing {file} to SY{o.Drive}: as {DiskTypes.Name(type)}, volume {volume}");
    Console.WriteLine("Existing data on the disk will be overwritten.");

    using var client = Connect(o);
    client.SetType(type);
    client.SetVolume(volume);
    client.WriteImage(type, image, o.StartDelayMs, Progress, CancelOnCtrlC());
    Console.WriteLine("Done.");
    return 0;
}

static H8Client Connect(Options o)
{
    var port = o.Port ?? throw new UsageException("--port is required");
    var client = new H8Client(port, o.Baud) { Log = msg => Console.Error.WriteLine($"warning: {msg}") };
    try
    {
        client.Probe();
        client.SelectDrive(o.Drive);
        return client;
    }
    catch
    {
        client.Dispose();
        throw;
    }
}

// First Ctrl+C stops the transfer cleanly between tracks; a second one kills
// the process.
static CancellationToken CancelOnCtrlC()
{
    var cts = new CancellationTokenSource();
    Console.CancelKeyPress += (_, e) =>
    {
        if (!cts.IsCancellationRequested)
        {
            e.Cancel = true;
            cts.Cancel();
        }
    };
    return cts.Token;
}

static void Progress(int track, int tracks)
{
    Console.Write($"\rTrack {track + 1,3}/{tracks}");
    if (track + 1 == tracks)
    {
        Console.WriteLine();
    }
}

static void Usage()
{
    Console.WriteLine("""
        h8dimghost - PC host for H8DIMGR4

        Usage:
          h8dimghost ports
          h8dimghost query --port <port> [--drive 0|1]
          h8dimghost read  <image> --port <port> [--drive 0|1] [--type T] [--volume N] [--force]
          h8dimghost write <image> --port <port> [--drive 0|1] [--type T] [--volume N] [--start-delay ms]

        Options:
          --port, -p      Serial port (e.g. COM3, /dev/cu.usbserial-1410)
          --drive, -d     0 = SY0: (40 track), 1 = SY1: (80 track). Default 0
          --type, -t      1s40, 2s40, 1s80, 2s80. Read: default is auto-detect.
                          Write: default is from image size (204,800 bytes is
                          2s40 on SY0: and 1s80 on SY1:)
          --volume, -v    Volume number 0-255. Read: default from the disk header.
                          Write: default from the HDOS label, else 0
          --baud, -b      Default 38400
          --start-delay   Write only: ms to wait for the drive to seek and sync
                          before sending the first track. Default 2000
          --force, -f     Read only: overwrite an existing output file
        """);
}

sealed class UsageException(string message) : Exception(message);

sealed class Options
{
    public string? Port;
    public string? File;
    public int Drive;
    public DiskType? Type;
    public byte? Volume;
    public int Baud = 38400;
    public int StartDelayMs = 2000;
    public bool Force;

    public static Options Parse(string[] args)
    {
        var o = new Options();
        for (int i = 0; i < args.Length; i++)
        {
            string a = args[i];
            string Next() => i + 1 < args.Length ? args[++i] : throw new UsageException($"{a} needs a value");

            switch (a)
            {
                case "--port": case "-p":
                    o.Port = Next();
                    break;
                case "--drive": case "-d":
                    o.Drive = Next() switch
                    {
                        "0" or "sy0" or "SY0" or "SY0:" or "sy0:" => 0,
                        "1" or "sy1" or "SY1" or "SY1:" or "sy1:" => 1,
                        var bad => throw new UsageException($"Bad drive '{bad}', use 0 or 1"),
                    };
                    break;
                case "--type": case "-t":
                    var ts = Next();
                    o.Type = DiskTypes.TryParse(ts, out var t) ? t : throw new UsageException($"Bad type '{ts}'");
                    break;
                case "--volume": case "-v":
                    var vs = Next();
                    o.Volume = byte.TryParse(vs, out var v) ? v : throw new UsageException($"Bad volume '{vs}', use 0-255");
                    break;
                case "--baud": case "-b":
                    var bs = Next();
                    o.Baud = int.TryParse(bs, out var b) && b > 0 ? b : throw new UsageException($"Bad baud '{bs}'");
                    break;
                case "--start-delay":
                    var ds = Next();
                    o.StartDelayMs = int.TryParse(ds, out var d) && d >= 0 ? d : throw new UsageException($"Bad delay '{ds}'");
                    break;
                case "--force": case "-f":
                    o.Force = true;
                    break;
                default:
                    if (a.StartsWith('-'))
                    {
                        throw new UsageException($"Unknown option '{a}'");
                    }
                    if (o.File is not null)
                    {
                        throw new UsageException($"Unexpected argument '{a}'");
                    }
                    o.File = a;
                    break;
            }
        }
        return o;
    }
}
