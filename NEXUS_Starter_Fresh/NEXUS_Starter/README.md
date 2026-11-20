# NEXUS Control Center — Starter Prototype

This is a clean Windows WPF starter project for the NEXUS companion application.

## What works in this prototype
- Windows desktop UI with Overview, Game Library, Performance, and System navigation.
- Displays the current Windows session and machine name.
- Launch Steam through its registered Windows protocol handler.
- Opens Windows Settings.
- Reports status/errors inside the app.

## What is intentionally not implemented
This is **not NEXUS OS** and it does not install Linux, create partitions, alter EFI/BCD/GRUB, change the default boot entry, or reboot the PC. Those features need a separately designed and carefully tested Linux installer/boot-management component, recovery plan, and explicit user confirmation. Do not add boot-changing commands casually.

The Game Library and Performance pages are clearly marked as planned modules. They do not pretend to scan games or tune hardware yet.

## Requirements
- Windows 10/11, 64-bit
- .NET 8 SDK (the Windows Desktop Runtime alone is not enough to build)
- PowerShell

Get the .NET 8 SDK from the official Microsoft .NET download page:
https://dotnet.microsoft.com/en-us/download/dotnet/8.0

## Build
1. Extract the ZIP.
2. Open PowerShell.
3. Change into the folder containing `NexusControlCenter.csproj`, for example:

   ```powershell
   cd "$HOME\Downloads\NEXUS_Starter\NexusControlCenter"
   ```

4. Build:

   ```powershell
   dotnet clean
   dotnet build -c Release
   ```

5. Run:

   ```powershell
   dotnet run
   ```

The executable will be under:

`bin\Release\net8.0-windows\NEXUS Control Center.exe`

## Publish a self-contained Windows build
Run from the project folder:

```powershell
dotnet publish -c Release -r win-x64 --self-contained true /p:PublishSingleFile=true
```

Published files will be in:

`bin\Release\net8.0-windows\win-x64\publish\`

## Troubleshooting
- `MSB1003`: PowerShell is not in the folder containing the `.csproj`. Run `Get-ChildItem -Recurse -Filter *.csproj` from the extracted folder and `cd` into the result's directory.
- `NETSDK...` or missing targeting pack: install the .NET 8 SDK, then reopen PowerShell.
- If Steam does not launch, install Steam or open it manually. The app uses Windows' registered `steam://` handler.

## Project structure
```text
NEXUS_Starter/
  README.md
  build.ps1
  NexusControlCenter/
    NexusControlCenter.csproj
    App.xaml
    App.xaml.cs
    MainWindow.xaml
    MainWindow.xaml.cs
    app.manifest
```
