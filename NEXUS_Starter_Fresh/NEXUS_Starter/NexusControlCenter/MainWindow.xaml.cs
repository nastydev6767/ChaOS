using System.Diagnostics;
using System.Windows;

namespace NexusControlCenter;

public partial class MainWindow : Window
{
    public MainWindow()
    {
        InitializeComponent();
        OsValue.Text = "Windows";
        DeviceValue.Text = Environment.MachineName;
        StatusText.Text = $"Ready • {Environment.OSVersion.VersionString}";
    }

    private void SetPage(string title, string subtitle, string status)
    {
        PageTitle.Text = title;
        PageSubtitle.Text = subtitle;
        StatusText.Text = status;
    }

    private void Overview_Click(object sender, RoutedEventArgs e) =>
        SetPage("Overview", "Your gaming environment, at a glance.", "Overview selected.");

    private void Library_Click(object sender, RoutedEventArgs e) =>
        SetPage("Game Library", "A home for your installed and compatible games.",
            "Game Library is a planned module. This prototype does not scan or modify game installations.");

    private void Performance_Click(object sender, RoutedEventArgs e) =>
        SetPage("Performance", "Understand your system before tuning it.",
            "Performance profiles are planned. No power, registry, driver, or system settings have been changed.");

    private void System_Click(object sender, RoutedEventArgs e) =>
        SetPage("System", "System information and NEXUS environment status.",
            $"Computer: {Environment.MachineName} • OS: {Environment.OSVersion}");

    private void LaunchSteam_Click(object sender, RoutedEventArgs e)
    {
        try
        {
            Process.Start(new ProcessStartInfo("steam://open/main") { UseShellExecute = true });
            StatusText.Text = "Sent a request to Windows to open Steam. If Steam is not installed, nothing will happen.";
        }
        catch (Exception ex)
        {
            StatusText.Text = $"Could not open Steam: {ex.Message}";
        }
    }

    private void OpenSettings_Click(object sender, RoutedEventArgs e)
    {
        try
        {
            Process.Start(new ProcessStartInfo("ms-settings:") { UseShellExecute = true });
            StatusText.Text = "Opened Windows Settings.";
        }
        catch (Exception ex)
        {
            StatusText.Text = $"Could not open Windows Settings: {ex.Message}";
        }
    }
}
