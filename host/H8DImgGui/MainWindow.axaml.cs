using System.Collections.ObjectModel;
using System.Diagnostics;
using Avalonia.Controls;
using Avalonia.Input.Platform;
using Avalonia.Interactivity;
using Avalonia.Media;
using Avalonia.Platform.Storage;
using Avalonia.Threading;
using H8DImgHost;

namespace H8DImgGui;

public partial class MainWindow : Window
{
    const int MaxLogEntries = 5000;

    static readonly FilePickerFileType ImageFileType = new("H8D disk image") { Patterns = ["*.h8d"] };

    readonly ObservableCollection<LogEntry> log = [];
    readonly ObservableCollection<TrackCell> side0 = [];
    readonly ObservableCollection<TrackCell> side1 = [];
    TrackCell[] cells = [];     // indexed by logical track

    H8Client? client;
    CancellationTokenSource? cancel;
    bool busy;

    public MainWindow()
    {
        InitializeComponent();

        LogList.ItemsSource = log;
        Side0Map.ItemsSource = side0;
        Side1Map.ItemsSource = side1;

        BaudBox.ItemsSource = new[] { 9600, 19200, 38400, 57600 };
        BaudBox.SelectedItem = 38400;

        TypeBox.ItemsSource = new[]
        {
            new TypeOption("Auto-detect", null),
            new TypeOption("1S40T  ·  single sided, 40 track", DiskType.SS40),
            new TypeOption("2S40T  ·  double sided, 40 track", DiskType.DS40),
            new TypeOption("1S80T  ·  single sided, 80 track", DiskType.SS80),
            new TypeOption("2S80T  ·  double sided, 80 track", DiskType.DS80),
        };
        TypeBox.SelectedIndex = 0;

        RefreshPorts();
        ResetTrackMap(DiskType.SS40);
        SetOperation("Idle", "Connect to H8DIMGR4 to begin");
        UpdateUi();

        Log("Start H8DIMGR4 on the H8, choose the serial port and click Connect.");
        Closing += (_, _) =>
        {
            cancel?.Cancel();
            client?.Dispose();
        };
    }

    int Drive => Sy1Radio.IsChecked == true ? 1 : 0;

    DiskType? SelectedType => (TypeBox.SelectedItem as TypeOption)?.Type;

    // ---- Connection --------------------------------------------------------

    void OnRefreshPorts(object? sender, RoutedEventArgs e) => RefreshPorts();

    void RefreshPorts()
    {
        var current = PortBox.SelectedItem as string;
        var ports = H8Client.AvailablePorts();
        PortBox.ItemsSource = ports;
        PortBox.SelectedItem = ports.Contains(current) ? current
            : ports.FirstOrDefault(p => p.Contains("usb", StringComparison.OrdinalIgnoreCase)) ?? ports.FirstOrDefault();
    }

    async void OnConnect(object? sender, RoutedEventArgs e)
    {
        if (client is not null)
        {
            Disconnect();
            return;
        }
        if (PortBox.SelectedItem is not string port)
        {
            Log("Choose a serial port first.", LogLevel.Error);
            return;
        }
        int baud = BaudBox.SelectedItem as int? ?? 38400;

        busy = true;
        UpdateUi();
        Log($"Opening {port} at {baud:N0} baud…");
        try
        {
            client = await Task.Run(() =>
            {
                var c = new H8Client(port, baud) { Log = msg => Ui(() => Log(msg, LogLevel.Warn)) };
                try
                {
                    c.Probe();
                    return c;
                }
                catch
                {
                    c.Dispose();
                    throw;
                }
            });
            Log("Connected. H8DIMGR4 is responding.", LogLevel.Success);
            SetOperation("Ready", $"Connected on {port}");
        }
        catch (Exception ex)
        {
            Log($"Connect failed: {ex.Message}", LogLevel.Error);
        }
        finally
        {
            busy = false;
            UpdateUi();
        }
    }

    void Disconnect()
    {
        client?.Dispose();
        client = null;
        Log("Disconnected.");
        SetOperation("Idle", "Connect to H8DIMGR4 to begin");
        UpdateUi();
    }

    // ---- Operations --------------------------------------------------------

    async void OnQuery(object? sender, RoutedEventArgs e)
    {
        int drive = Drive;
        SetOperation("Querying", $"Detecting disk in SY{drive}:");
        await RunOperation("Query", (c, _) =>
        {
            c.SelectDrive(drive);
            var type = c.Query();
            if (type is null)
            {
                Ui(() =>
                {
                    Log($"Could not determine the disk type in SY{drive}:. Is a formatted disk inserted?", LogLevel.Warn);
                    SetOperation("Query failed", "Disk type unknown");
                });
                return;
            }
            byte volume = c.GetHdosVolume();
            Ui(() =>
            {
                Log($"SY{drive}: holds a {DiskTypes.Name(type.Value)} disk.", LogLevel.Success);
                Log($"HDOS label volume: {volume} (only meaningful for HDOS disks)", LogLevel.Detail);
                ResetTrackMap(type.Value);
                SetOperation("Disk detected", $"SY{drive}:  ·  {DiskTypes.Name(type.Value)}  ·  volume {volume}");
            });
        });
    }

    async void OnRead(object? sender, RoutedEventArgs e)
    {
        if (!TryGetVolume(out var volume))
        {
            return;
        }
        int drive = Drive;
        var typeOverride = SelectedType;

        var file = await StorageProvider.SaveFilePickerAsync(new FilePickerSaveOptions
        {
            Title = "Save disk image as",
            SuggestedFileName = "disk.h8d",
            DefaultExtension = "h8d",
            FileTypeChoices = [ImageFileType],
            ShowOverwritePrompt = true,
        });
        var path = file?.TryGetLocalPath();
        if (path is null)
        {
            return;
        }

        SetOperation("Reading", $"SY{drive}:  →  {Path.GetFileName(path)}");
        await RunOperation("Read", (c, token) =>
        {
            Ui(() => Log($"Reading SY{drive}: to {path}"));
            c.SelectDrive(drive);
            var type = c.PrepareRead(typeOverride, volume, msg => Ui(() => Log(msg, LogLevel.Detail)));
            Ui(() => BeginTransfer(type, "Reading", $"SY{drive}:  →  {Path.GetFileName(path)}  ·  {DiskTypes.Name(type)}"));

            var image = c.ReadImage(type, TrackProgress("read"), token);
            File.WriteAllBytes(path, image);
            Ui(() =>
            {
                Log($"Saved {image.Length:N0} bytes to {path}", LogLevel.Success);
                SetOperation("Read complete", $"SY{drive}:  →  {Path.GetFileName(path)}");
            });
        });
    }

    async void OnWrite(object? sender, RoutedEventArgs e)
    {
        if (!TryGetVolume(out var volumeOverride))
        {
            return;
        }
        int drive = Drive;
        int startDelay = (int)(DelayBox.Value ?? 2000);

        var files = await StorageProvider.OpenFilePickerAsync(new FilePickerOpenOptions
        {
            Title = "Choose a disk image to write",
            AllowMultiple = false,
            FileTypeFilter = [ImageFileType, FilePickerFileTypes.All],
        });
        var path = files.FirstOrDefault()?.TryGetLocalPath();
        if (path is null)
        {
            return;
        }

        byte[] image;
        try
        {
            image = await File.ReadAllBytesAsync(path);
        }
        catch (Exception ex)
        {
            Log($"Can't read {path}: {ex.Message}", LogLevel.Error);
            return;
        }

        var type = SelectedType ?? DiskTypes.FromImageSize(image.Length, drive);
        if (type is null)
        {
            Log($"Can't tell the disk format from the image size ({image.Length:N0} bytes). Choose a format.", LogLevel.Error);
            return;
        }
        if (image.Length != DiskTypes.ImageSize(type.Value))
        {
            Log($"{Path.GetFileName(path)} is {image.Length:N0} bytes but {DiskTypes.Name(type.Value)} needs {DiskTypes.ImageSize(type.Value):N0}.", LogLevel.Error);
            return;
        }

        var labelVolume = DiskTypes.HdosLabelVolume(image);
        byte volume = volumeOverride ?? labelVolume ?? 0;
        string volumeSource = volumeOverride is not null ? "entered"
            : labelVolume is not null ? "from HDOS label" : "default, no HDOS label";

        bool ok = await ConfirmDialog.Show(this, "Overwrite disk?",
            $"The disk in SY{drive}: will be formatted and everything on it replaced with:\n\n" +
            $"{Path.GetFileName(path)}\n{DiskTypes.Name(type.Value)}  ·  volume {volume} ({volumeSource})",
            "Write Disk");
        if (!ok)
        {
            return;
        }

        SetOperation("Writing", $"{Path.GetFileName(path)}  →  SY{drive}:");
        await RunOperation("Write", (c, token) =>
        {
            Ui(() => Log($"Writing {path} to SY{drive}: as {DiskTypes.Name(type.Value)}, volume {volume} ({volumeSource})"));
            c.SelectDrive(drive);
            c.SetType(type.Value);
            c.SetVolume(volume);
            Ui(() => BeginTransfer(type.Value, "Writing", $"{Path.GetFileName(path)}  →  SY{drive}:  ·  {DiskTypes.Name(type.Value)}"));

            c.WriteImage(type.Value, image, startDelay, TrackProgress("formatted + wrote"), token);
            Ui(() =>
            {
                Log($"Wrote {image.Length:N0} bytes to SY{drive}:", LogLevel.Success);
                SetOperation("Write complete", $"{Path.GetFileName(path)}  →  SY{drive}:");
            });
        });
    }

    void OnCancel(object? sender, RoutedEventArgs e)
    {
        if (cancel is { IsCancellationRequested: false })
        {
            Log("Cancelling after the current track…", LogLevel.Warn);
            cancel.Cancel();
            UpdateUi();
        }
    }

    // Runs blocking client work off the UI thread with consistent busy state
    // and error reporting.
    async Task RunOperation(string name, Action<H8Client, CancellationToken> work)
    {
        if (client is null || busy)
        {
            return;
        }
        var c = client;
        busy = true;
        cancel = new CancellationTokenSource();
        UpdateUi();
        try
        {
            await Task.Run(() => work(c, cancel.Token));
        }
        catch (OperationCanceledException)
        {
            MarkActive(CellState.Pending);
            Log($"{name} cancelled. H8DIMGR4 is back at its command prompt.", LogLevel.Warn);
            SetOperation($"{name} cancelled", OpDetail.Text ?? "");
        }
        catch (Exception ex)
        {
            MarkActive(CellState.Error);
            Log($"{name} failed: {ex.Message}", LogLevel.Error);
            SetOperation($"{name} failed", ex.Message);
            if (ex is TimeoutException)
            {
                Log("H8DIMGR4 stopped responding. If it doesn't recover, restart it on the H8 and reconnect.", LogLevel.Detail);
            }
            else if (ex is IOException or InvalidOperationException or UnauthorizedAccessException)
            {
                Disconnect();
            }
        }
        finally
        {
            busy = false;
            cancel.Dispose();
            cancel = null;
            UpdateUi();
        }
    }

    // ---- Progress ----------------------------------------------------------

    Stopwatch transferClock = new();

    void BeginTransfer(DiskType type, string title, string detail)
    {
        ResetTrackMap(type);
        cells[0].State = CellState.Active;
        Progress.Value = 0;
        PercentText.Text = "0%";
        StatTrack.Text = $"0/{cells.Length}";
        StatSpeed.Text = "–";
        StatElapsed.Text = "0:00";
        StatEta.Text = "–";
        SetOperation(title, detail);
        transferClock = Stopwatch.StartNew();
    }

    // Called on the worker thread after each track; times the track there so
    // UI latency doesn't skew the numbers.
    Action<int, int> TrackProgress(string verb)
    {
        var clock = Stopwatch.StartNew();
        double last = 0;
        return (track, tracks) =>
        {
            double now = clock.Elapsed.TotalSeconds;
            double lap = now - last;
            last = now;
            Ui(() => OnTrackDone(track, tracks, lap, verb));
        };
    }

    void OnTrackDone(int track, int tracks, double lapSeconds, string verb)
    {
        cells[track].State = CellState.Done;
        if (track + 1 < tracks)
        {
            cells[track + 1].State = CellState.Active;
        }

        int done = track + 1;
        double elapsed = transferClock.Elapsed.TotalSeconds;
        double bytesPerSec = done * DiskTypes.TrackSize / Math.Max(elapsed, 0.001);
        double remaining = elapsed / done * (tracks - done);

        Progress.Value = 100.0 * done / tracks;
        PercentText.Text = $"{100 * done / tracks}%";
        StatTrack.Text = $"{done}/{tracks}";
        StatSpeed.Text = $"{bytesPerSec / 1024:0.0} KB/s";
        StatElapsed.Text = FormatTime(elapsed);
        StatEta.Text = done == tracks ? "0:00" : FormatTime(remaining);

        var (cyl, side) = CylSide(track);
        Log($"Track {track,3}  cyl {cyl,2} side {side}  {verb} {DiskTypes.TrackSize:N0} bytes  {lapSeconds,5:0.00}s",
            LogLevel.Detail);
    }

    static string FormatTime(double seconds)
    {
        var t = TimeSpan.FromSeconds(Math.Round(seconds));
        return t.TotalHours >= 1 ? t.ToString(@"h\:mm\:ss") : t.ToString(@"m\:ss");
    }

    bool doubleSided;

    (int cyl, int side) CylSide(int track) => doubleSided ? (track / 2, track % 2) : (track, 0);

    void ResetTrackMap(DiskType type)
    {
        doubleSided = type is DiskType.DS40 or DiskType.DS80;
        int tracks = DiskTypes.Tracks(type);
        int cylinders = doubleSided ? tracks / 2 : tracks;

        side0.Clear();
        side1.Clear();
        cells = new TrackCell[tracks];
        for (int t = 0; t < tracks; t++)
        {
            var (cyl, side) = CylSide(t);
            cells[t] = new TrackCell(t, cyl, side);
        }
        // Rows are filled in cylinder order so each column is one cylinder
        foreach (var cell in cells.Where((_, t) => CylSide(t).side == 0))
        {
            side0.Add(cell);
        }
        foreach (var cell in cells.Where((_, t) => CylSide(t).side == 1))
        {
            side1.Add(cell);
        }

        Side1Map.IsVisible = Side1Label.IsVisible = doubleSided;
        LastCylLabel.Text = $"cyl {cylinders - 1}";
    }

    void MarkActive(CellState state)
    {
        foreach (var cell in cells.Where(c => c.IsActive))
        {
            cell.State = state;
        }
    }

    // ---- UI helpers --------------------------------------------------------

    void SetOperation(string title, string detail)
    {
        OpTitle.Text = title;
        OpDetail.Text = detail;
    }

    bool TryGetVolume(out byte? volume)
    {
        volume = null;
        var text = VolumeBox.Text?.Trim();
        if (string.IsNullOrEmpty(text))
        {
            return true;
        }
        if (byte.TryParse(text, out var v))
        {
            volume = v;
            return true;
        }
        Log($"Volume must be 0-255 or blank for auto, not '{text}'.", LogLevel.Error);
        return false;
    }

    void UpdateUi()
    {
        bool connected = client is not null;
        bool idle = !busy;

        PortBox.IsEnabled = RefreshButton.IsEnabled = BaudBox.IsEnabled = !connected && idle;
        ConnectButton.IsEnabled = idle;
        ConnectButton.Content = connected ? "Disconnect" : "Connect";
        DiskPanel.IsEnabled = idle;
        QueryButton.IsEnabled = ReadButton.IsEnabled = WriteButton.IsEnabled = connected && idle;
        CancelButton.IsEnabled = cancel is { IsCancellationRequested: false };

        StatusDot.Fill = connected
            ? new SolidColorBrush(Color.Parse(busy ? "#E3A008" : "#2EA043"))
            : new SolidColorBrush(Color.Parse("#8B929E"));
        StatusText.Text = connected
            ? $"{(busy ? "Busy" : "Connected")}  ·  {client!.PortName}"
            : "Not connected";
    }

    void Log(string text, LogLevel level = LogLevel.Info)
    {
        log.Add(new LogEntry(text, level));
        while (log.Count > MaxLogEntries)
        {
            log.RemoveAt(0);
        }
        Dispatcher.UIThread.Post(() => LogScroll.ScrollToEnd(), DispatcherPriority.Background);
    }

    static void Ui(Action action) => Dispatcher.UIThread.Post(action);

    async void OnCopyLog(object? sender, RoutedEventArgs e)
    {
        if (Clipboard is { } clipboard)
        {
            await clipboard.SetTextAsync(string.Join(Environment.NewLine, log));
        }
    }

    void OnClearLog(object? sender, RoutedEventArgs e) => log.Clear();
}
