# H8DIMGR
Heathkit client to work alongside [H8DUtility 3](https://github.com/lesbird/H8DUtility3)

A utility written in 8080 ASM to send and receive disk images from a PC/Mac running H8DUtility 3. Sends data at 38,400 baud. A full one sided 40 track disk image can be send to H8DUtility in less than 1 minute and received from H8DUtility in a little more than a minute.

H8DIMGR2.ASM - deprecated<br>
H8DIMGR3.ASM - deprecated<br>
H8DIMGR4.ASM - current

On the Heathkit H8/H89 computer assemble the source file as follows<br>
Requires all supporting ACM files to be on the drive where H8DIMGR4.ASM resides<br>
In HDOS 2 if ASM.ABS is in SY0: and H8DIMGR4.ASM is in drive SY1:<br>

>ASM SY1:H8DIMGR4,=SY1:H8DIMGR4<br>

This will create H8DIMGR4.ABS on the SY1: drive

H8DIMGR4.ASM has been completely rewritten from the ground up. The code has been cleaned up and all jump vectors are restored from the ULTIMETH HSY driver routines to the original ROM routines. Only the necessary jump vectors (D.DTS and D.SDT) are intercepted and overridden to support multisided disks.

## H8DIMGR Host (C# GUI and command line)

`host/` contains a cross-platform .NET 10 host that talks to H8DIMGR4 directly (an alternative to H8DUtility 3). It runs on Windows, macOS and Linux.

- `H8DImgGui` - desktop app (Avalonia): connect, query, read and write with a live track map, throughput/ETA and a scrollable status log
- `H8DImgHost` - command line tool (`h8dimghost`)
- `H8DImgCore` - the shared H8DIMGR4 protocol code

Prebuilt Windows, macOS and Linux versions (no .NET install needed) are on the [Releases](https://github.com/lesbird/H8DIMGR/releases) page.

To start the GUI from the repository root, run `./run.sh` (macOS/Linux) or `run.cmd` (Windows).

```
cd host
dotnet run --project H8DImgGui
dotnet run --project H8DImgHost -- ports
dotnet run --project H8DImgHost -- read  disk.h8d --port COM3 --drive 0
dotnet run --project H8DImgHost -- write disk.h8d --port COM3 --drive 1 --type 1s80
```

Reads auto-detect the disk type and volume. Writes infer the type from the image size (204,800 bytes is 2S40T on SY0: and 1S80T on SY1:) and the volume from the HDOS label. Override either with the format/volume settings (`--type` / `--volume`). Cancel stops between tracks and returns H8DIMGR4 to its command prompt.

## Host protocol flow

Every operation goes through `H8Client` (`host/H8DImgCore/H8Client.cs`), so the GUI and the command line send the same bytes. All traffic is on port 340Q at 38,400 baud, 8 data bits, no parity, 2 stop bits.

### Connect

| Host sends | H8DIMGR4 does | Host expects |
|---|---|---|
| opens the port, clears buffers | | |
| `A` | echoes it (no-op command) | `A` within 1.5 s |

If `A` doesn't come back, the host retries up to 3 times. The retry also recovers an H8 left in the middle of a transfer by an interrupted session: the first stray byte sends it back to its command loop. The port then stays open until Disconnect.

Every operation below starts by selecting the drive:

| Host sends | H8DIMGR4 does | Host expects |
|---|---|---|
| `0` or `1` | selects SY0: or SY1: | the same byte echoed |

### Query disk

| Host sends | H8DIMGR4 does | Host expects |
|---|---|---|
| `Q` | echoes `Q`, seeks to cylinder 4 side 0 and reads a sector header | `Q` |
| | header track 4 means single-sided, 8 or 9 means double-sided; the drive decides 40 or 80 tracks | type byte `0`-`3`, or `FF` if it couldn't tell |
| `C` | reads track 0 and returns byte 0x900, the HDOS label volume | volume byte, then `C` |

Query also loads H8DIMGR4's volume setting from the track 4 header, which a read depends on.

### Read disk to image

1. **Setup:**
   - The host sends `Q` (as above) to detect the type and load the volume.
   - If a format was chosen, it sends `4`-`7` (1S40/2S40/1S80/2S80) and waits for the echo.
   - If a volume was entered, it sends `V` plus the volume byte and waits for `V`.
   - If detection failed and no volume was entered, it sends `V` with volume 0 and logs a warning.
2. **Transfer:**
   ```
   Host -> R                        (enter read mode, no reply)
   loop for each logical track (40 / 80 / 80 / 160):
       Host -> R                    (request next track)
       H8   -> 2560 bytes           (10 sectors x 256)
       H8   -> R                    (track done)
   ```
   H8DIMGR4 reads track 0 with volume 0 and later tracks with the header volume. On double-sided disks, logical track N is cylinder N/2, side N%2. After the last track it seeks to track 0 and returns to its command loop.
3. The host saves the image to the file.

### Write image to disk

1. **Format:** the one chosen, or worked out from the file size:
   - 102,400 bytes is 1S40
   - 204,800 bytes is 2S40 on SY0: or 1S80 on SY1:
   - 409,600 bytes is 2S80
2. **Volume:** the one entered, otherwise byte 0x900 if the image has a valid HDOS label, otherwise 0.
3. **Setup:** select the drive, then send `4`-`7` (type) and `V` plus the volume, waiting for each echo.
4. **Transfer:**
   ```
   Host -> W                        (enter write mode, no reply)
   Host waits the start delay       (default 2 s; H8DIMGR4 is seeking to
                                     track 0 and syncing; the 8250 has no
                                     FIFO, so data sent now would be lost)
   loop for each logical track:
       Host -> W + 2560 bytes
       H8: formats the track (headers carry volume and track number),
           then writes the 10 sectors
       H8   -> W                    (success)  or  ?  (disk error, host stops)
   ```
   H8DIMGR4 writes volume 0 on track 0 and the chosen volume on the other tracks.

### Cancel

Cancel takes effect between tracks, not in the middle of one.

| During | Host sends | H8DIMGR4 does |
|---|---|---|
| Read | `A` instead of the next `R` | treats it as abort, replies `R`, returns to its command loop |
| Write | `A` instead of the next `W` | aborts without a reply, returns to its command loop |

The host waits 0.5 s and discards anything received. H8DIMGR4 is then ready for the next command without a restart.

### Timeouts and errors

| Situation | Timeout |
|---|---|
| Command echoes | 5 s |
| Query, track read, track format + write | 20 s each |

On a timeout the GUI marks the current track red and suggests restarting H8DIMGR4. A serial port error disconnects the GUI. The serial data itself is not checksummed, so a corrupted byte on the line goes into the image or onto the disk undetected.
