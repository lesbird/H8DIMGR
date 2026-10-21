using System.ComponentModel;
using H8DImgHost;

namespace H8DImgGui;

public enum LogLevel { Info, Success, Warn, Error, Detail }

public sealed class LogEntry(string text, LogLevel level)
{
    public string Time { get; } = DateTime.Now.ToString("HH:mm:ss");
    public string Text { get; } = text;
    public bool IsSuccess => level == LogLevel.Success;
    public bool IsWarn => level == LogLevel.Warn;
    public bool IsError => level == LogLevel.Error;
    public bool IsDetail => level == LogLevel.Detail;

    public override string ToString() => $"{Time}  {Text}";
}

public enum CellState { Pending, Active, Done, Error }

// One logical track in the track map
public sealed class TrackCell(int track, int cylinder, int side) : INotifyPropertyChanged
{
    CellState state;

    public event PropertyChangedEventHandler? PropertyChanged;

    public string Tip { get; } = $"Track {track}  ·  cylinder {cylinder}, side {side}";

    public CellState State
    {
        get => state;
        set
        {
            if (state == value)
            {
                return;
            }
            state = value;
            foreach (var name in new[] { nameof(State), nameof(IsActive), nameof(IsDone), nameof(IsError) })
            {
                PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
            }
        }
    }

    public bool IsActive => state == CellState.Active;
    public bool IsDone => state == CellState.Done;
    public bool IsError => state == CellState.Error;
}

public sealed record TypeOption(string Label, DiskType? Type)
{
    public override string ToString() => Label;
}
