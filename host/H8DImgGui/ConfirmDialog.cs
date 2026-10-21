using Avalonia.Controls;
using Avalonia.Layout;
using Avalonia.Media;

namespace H8DImgGui;

static class ConfirmDialog
{
    public static Task<bool> Show(Window owner, string title, string message, string confirmText)
    {
        var dialog = new Window
        {
            Title = title,
            Width = 440,
            SizeToContent = SizeToContent.Height,
            CanResize = false,
            ShowInTaskbar = false,
            WindowStartupLocation = WindowStartupLocation.CenterOwner,
        };

        var cancel = new Button { Content = "Cancel", Padding = new(16, 7), IsCancel = true };
        var confirm = new Button { Content = confirmText, Padding = new(16, 7), IsDefault = true };
        confirm.Classes.Add("accent");
        cancel.Click += (_, _) => dialog.Close(false);
        confirm.Click += (_, _) => dialog.Close(true);

        dialog.Content = new StackPanel
        {
            Margin = new(22),
            Spacing = 14,
            Children =
            {
                new TextBlock { Text = title, FontSize = 17, FontWeight = FontWeight.SemiBold },
                new TextBlock { Text = message, TextWrapping = TextWrapping.Wrap, LineHeight = 20 },
                new StackPanel
                {
                    Orientation = Orientation.Horizontal,
                    HorizontalAlignment = HorizontalAlignment.Right,
                    Spacing = 8,
                    Margin = new(0, 8, 0, 0),
                    Children = { cancel, confirm },
                },
            },
        };

        return dialog.ShowDialog<bool>(owner);
    }
}
