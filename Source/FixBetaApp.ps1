# THIS IS MEANT TO RUN THROUGH AN EXE FILE (MAY BREAK IF YOU RUN THE RAW SCRIPT)
# You can compile this script using ps2exe or download my pre-compiled version in releases!
# https://github.com/InstanceBrick/RobloxBetaAppFix/releases - Releases (Auto updater recommended!)

$Global:IsEnabled = $true
function numInstances([string]$process) {
    @(get-process -ea silentlycontinue $process).count
}

Add-Type -AssemblyName System.Windows.Forms
if ((numInstances FixBetaApp) -gt 1) {
    $global:balloon = New-Object System.Windows.Forms.NotifyIcon
    $path = (Get-Process -id $pid).Path
    $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
    $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Error
    $balloon.BalloonTipText = 'Multiple instances opened (Please only open 1 instance)'
    $balloon.BalloonTipTitle = "Error!"
    $balloon.Visible = $true
    $balloon.ShowBalloonTip(1000)
    Stop-Process -Name FixBetaApp -Force
}

$global:balloon = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::None
$balloon.BalloonTipText = 'RobloxBetaFix has Loaded!'
$balloon.BalloonTipTitle = "Welcome!"
$balloon.Visible = $true
$balloon.ShowBalloonTip(1000)


if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript") {
    # Powershell script
    $ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}
else {
    # PS2EXE compiled script
    $ScriptPath = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0])
}


# Loads .NET libraries, flushing terminal output to null.
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')    | out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework')   | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')          | out-null
[System.Reflection.Assembly]::LoadWithPartialName('WindowsFormsIntegration') | out-null

$icon_resourse = [System.Drawing.Icon]::ExtractAssociatedIcon("$ScriptPath/FixBetaApp.exe")

$taskbar_icon = New-Object System.Windows.Forms.NotifyIcon
$taskbar_icon.Text = "FixBetaApp"
$taskbar_icon.Icon = $icon_resourse
$taskbar_icon.Visible = $true


$menu_exit = New-Object System.Windows.Forms.MenuItem
$menu_exit.Text = "Exit"

$menu_kill = New-Object System.Windows.Forms.MenuItem
$menu_kill.Text = "Kill Roblox"

$menu_toggle = New-Object System.Windows.Forms.MenuItem
$menu_toggle.Text = "Disable"


$menu_AttachedProcesses = New-Object System.Windows.Forms.MenuItem
$menu_AttachedProcesses.Enabled = $false
$menu_AttachedProcesses.Text = "Attached Processes: " + (numInstances RobloxPlayerBeta)

$contextmenu = New-Object System.Windows.Forms.ContextMenu
$taskbar_icon.ContextMenu = $contextmenu
$taskbar_icon.contextMenu.MenuItems.Add($menu_AttachedProcesses)
$taskbar_icon.contextMenu.MenuItems.Add("-")
$taskbar_icon.contextMenu.MenuItems.Add($menu_toggle)
$taskbar_icon.contextMenu.MenuItems.Add($menu_kill)
$taskbar_icon.contextMenu.MenuItems.Add($menu_exit)

# Hooks mouse-click event on taskbar icon to open context menu.
$taskbar_icon.Add_Click({
        If ($_.Button -eq [Windows.Forms.MouseButtons]::Left -or $_.Button -eq [Windows.Forms.MouseButtons]::Right) {
            $taskbar_icon.GetType().GetMethod("ShowContextMenu", [System.Reflection.BindingFlags]::Instance -bor [System.Reflection.BindingFlags]::NonPublic).Invoke($taskbar_icon, $null)
            # Refresh ContextMenu

            Start-Sleep -Milliseconds 1
            $menu_AttachedProcesses.Text = "Attached Processes: " + (numInstances RobloxPlayerBeta)

        }
    })


# Hooks mouse-click event on Kill button to force-quit RobloxPlayerBeta.
$menu_kill.add_Click({
        $roblox = Get-Process RobloxPlayerBeta -ErrorAction SilentlyContinue
        if ($roblox) {
            Stop-Process -Name RobloxPlayerBeta -Force
        }
    })

# Hooks mouse-click event on Exit button to terminate RobloxBetaFix.
$menu_exit.add_Click({
        $global:balloon = New-Object System.Windows.Forms.NotifyIcon
        $path = (Get-Process -id $pid).Path
        $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
        $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::None
        $balloon.BalloonTipText = 'RobloxBetaFix has closed!'
        $balloon.BalloonTipTitle = "Goodbye!"
        $balloon.Visible = $true
        $balloon.ShowBalloonTip(1000)
        $taskbar_icon.Visible = $false
        $taskbar_icon.Dispose()

        Stop-Job -Name "Loop"
        Stop-Process -Name FixBetaApp -Force

    })


$reg_loop = {
    $reg_key = "HKCU:\Software\ROBLOX Corporation\Environments\roblox-player"
    while ($true) {

        # We are getting the RobloxPlayerBeta PID and checking if it's running.
        # Then, if it starts to not respond, we close the program.
        $roblox = Get-Process RobloxPlayerBeta -ErrorAction SilentlyContinue
        if ($roblox) {
            if ((Get-Process RobloxPlayerBeta).Responding) {
                # Write-Output "Roblox Running Properly"
            }
            else {
                # Write-Output "Roblox Crash"
                #Stop-Process -Name RobloxPlayerBeta -Force

                # Sorts through all open processes and stops all EXCEPT for the most recently opened.
                Get-Process RobloxPlayerBeta |
                Sort-Object StartTime -Descending |
                Select-Object -Skip 1 |
                Stop-Process
            }
        }

        # Changes HKCU:\Software\ROBLOX Corporation\Environments\roblox-player\LaunchExp to "InBrowser".
        $reg_value = (Get-ItemProperty -Path $reg_key -Name "LaunchExp").LaunchExp
        if ($reg_value -eq "InApp") {
            # Write-Output "Value is InApp."
            Set-ItemProperty -Path $reg_key -Name "LaunchExp" -Value "InBrowser"
        }

        Write-Output $menu_toggle.Text
        Start-Sleep -Milliseconds 20
    }
}


# Hooks mouse-click event on Toggle button to force-quit RobloxPlayerBeta.
$menu_toggle.add_Click({
        if ($menu_toggle.Text -eq "Disable" ) {
            $menu_toggle.Text = "Enable"
            Stop-Job -Name "Loop"
        }
        else {
            $menu_toggle.Text = "Disable"
            Start-Job -ScriptBlock $reg_loop -Name "Loop"
        }
    })

Start-Job -ScriptBlock $reg_loop -Name "Loop"
[System.GC]::Collect()
Start-Sleep -Seconds 1
$global:balloon.Dispose()

# Create an application context for it to all run within.
# This helps with responsiveness, especially when clicking Exit.
$appContext = New-Object System.Windows.Forms.ApplicationContext
[void][System.Windows.Forms.Application]::Run($appContext)
