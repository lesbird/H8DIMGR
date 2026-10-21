namespace H8DImgHost;

// Values match DSKTYP in H8DIMGR4.ASM
public enum DiskType : byte
{
    SS40 = 0,   // 1S40T
    DS40 = 1,   // 2S40T
    SS80 = 2,   // 1S80T
    DS80 = 3,   // 2S80T
}

public static class DiskTypes
{
    public const int SectorSize = 256;
    public const int SectorsPerTrack = 10;
    public const int TrackSize = SectorSize * SectorsPerTrack;  // BUFSIZ = 2560

    // Logical tracks (sides * cylinders)
    public static int Tracks(DiskType t) => t switch
    {
        DiskType.SS40 => 40,
        DiskType.DS40 => 80,
        DiskType.SS80 => 80,
        DiskType.DS80 => 160,
        _ => throw new ArgumentOutOfRangeException(nameof(t)),
    };

    public static int ImageSize(DiskType t) => Tracks(t) * TrackSize;

    // Command bytes '4'..'7' select the disk type on the client
    public static byte Command(DiskType t) => (byte)('4' + (byte)t);

    public static string Name(DiskType t) => t switch
    {
        DiskType.SS40 => "1S40T (single sided, 40 track)",
        DiskType.DS40 => "2S40T (double sided, 40 track)",
        DiskType.SS80 => "1S80T (single sided, 80 track)",
        DiskType.DS80 => "2S80T (double sided, 80 track)",
        _ => $"unknown ({(byte)t})",
    };

    public static bool TryParse(string s, out DiskType t)
    {
        switch (s.ToLowerInvariant())
        {
            case "1s40": case "1s40t": case "ss40": t = DiskType.SS40; return true;
            case "2s40": case "2s40t": case "ds40": t = DiskType.DS40; return true;
            case "1s80": case "1s80t": case "ss80": t = DiskType.SS80; return true;
            case "2s80": case "2s80t": case "ds80": t = DiskType.DS80; return true;
        }
        t = default;
        return false;
    }

    // 204,800 bytes is ambiguous (2S40T or 1S80T); resolve it by drive per the
    // H8DIMGR4 configuration (SY0: = 40 track drive, SY1: = 80 track drive).
    public static DiskType? FromImageSize(long size, int drive) => size switch
    {
        40 * TrackSize => DiskType.SS40,
        80 * TrackSize => drive == 0 ? DiskType.DS40 : DiskType.SS80,
        160 * TrackSize => DiskType.DS80,
        _ => null,
    };

    // The HDOS label lives in sector 9 of track 0. Byte 0 is the volume serial;
    // bytes 0EH-0FH hold the physical sector size (256), which serves as a sanity
    // check that this really is an HDOS disk and not CP/M boot code.
    public static byte? HdosLabelVolume(byte[] image)
    {
        const int label = 9 * SectorSize;
        if (image.Length < label + SectorSize)
        {
            return null;
        }
        bool isHdos = image[label + 0x0E] == 0x00 && image[label + 0x0F] == 0x01;
        return isHdos ? image[label] : null;
    }
}
