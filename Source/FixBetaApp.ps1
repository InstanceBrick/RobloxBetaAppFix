# THIS IS MEANT TO RUN THROUGH AN EXE FILE (MAY BREAK IF YOU RUN THE RAW SCRIPT)
# You can compile this script using ps2exe or download my pre-compiled version in releases!
# https://github.com/InstanceBrick/RobloxBetaAppFix/releases/tag/v2.0.0up - Auto updater


# Check for multiple instances of the current program (stops errors/overlapping code)

function numInstances([string]$process)
{
    @(get-process -ea silentlycontinue $process).count
}
if ((numInstances FixBetaApp) -gt 1) {
Add-Type -AssemblyName System.Windows.Forms 
$global:balloon = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Error 
$balloon.BalloonTipText = 'Multiple instances opened (Please only open 1 instance)'
$balloon.BalloonTipTitle = "Error!" 
$balloon.Visible = $true 
$balloon.ShowBalloonTip(7000)
    Stop-Process -Name FixBetaApp -Force
}



$global:balloon = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::None 
$balloon.BalloonTipText = 'RobloxBetaFix has Loaded!'
$balloon.BalloonTipTitle = "Welcome!" 
$balloon.Visible = $true 
$balloon.ShowBalloonTip(7000)


if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript")
{ # Powershell script
	$ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}
else
{ # PS2EXE compiled script
	$ScriptPath = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0])
}



[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')       | out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework')      | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')          | out-null
[System.Reflection.Assembly]::LoadWithPartialName('WindowsFormsIntegration') | out-null

 

$icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$ScriptPath/FixBetaApp.exe")    

 

$Main_Tool_Icon = New-Object System.Windows.Forms.NotifyIcon
$Main_Tool_Icon.Text = "RobloxBetaFix"
$Main_Tool_Icon.Icon = $icon
$Main_Tool_Icon.Visible = $true


 

$Menu_Exit = New-Object System.Windows.Forms.MenuItem
$Menu_Exit.Text = "Exit"

$Menu_Kill = New-Object System.Windows.Forms.MenuItem
$Menu_Kill.Text = "Kill Roblox"

$Menu_AttachedProcesses = New-Object System.Windows.Forms.MenuItem
$Menu_AttachedProcesses.Enabled = $false
$Menu_AttachedProcesses.Text = "Attached Processes: " + (numInstances RobloxPlayerBeta)

$contextmenu = New-Object System.Windows.Forms.ContextMenu
$Main_Tool_Icon.ContextMenu = $contextmenu
$Main_Tool_Icon.contextMenu.MenuItems.Add($Menu_AttachedProcesses)
$Main_Tool_Icon.contextMenu.MenuItems.Add($Menu_Kill)
$Main_Tool_Icon.contextMenu.MenuItems.Add($Menu_Exit)


 
$Main_Tool_Icon.Add_Click({                    
    If ($_.Button -eq [Windows.Forms.MouseButtons]::Left) {
        $Main_Tool_Icon.GetType().GetMethod("ShowContextMenu",[System.Reflection.BindingFlags]::Instance -bor [System.Reflection.BindingFlags]::NonPublic).Invoke($Main_Tool_Icon,$null)
        #Refresh ContextMenu
        $Main_Tool_Icon.contextMenu.MenuItems.Remove($Menu_AttachedProcesses)
        $Main_Tool_Icon.contextMenu.MenuItems.Remove($Menu_Kill)
        $Main_Tool_Icon.contextMenu.MenuItems.Remove($Menu_Exit)
        Start-Sleep -Milliseconds 1
        $Menu_AttachedProcesses.Text = "Attached Processes: " + (numInstances RobloxPlayerBeta)
        $Main_Tool_Icon.contextMenu.MenuItems.Add($Menu_AttachedProcesses)
        $Main_Tool_Icon.contextMenu.MenuItems.Add($Menu_Kill)
        $Main_Tool_Icon.contextMenu.MenuItems.Add($Menu_Exit)
    }
})

$Main_Tool_Icon.Add_Click({                    
    If ($_.Button -eq [Windows.Forms.MouseButtons]::Right) {
        $Main_Tool_Icon.GetType().GetMethod("ShowContextMenu",[System.Reflection.BindingFlags]::Instance -bor [System.Reflection.BindingFlags]::NonPublic).Invoke($Main_Tool_Icon,$null)
        #Refresh ContextMenu
        $Main_Tool_Icon.contextMenu.MenuItems.Remove($Menu_AttachedProcesses)
        $Main_Tool_Icon.contextMenu.MenuItems.Remove($Menu_Kill)
        $Main_Tool_Icon.contextMenu.MenuItems.Remove($Menu_Exit)
        Start-Sleep -Milliseconds 1
        $Menu_AttachedProcesses.Text = "Attached Processes: " + (numInstances RobloxPlayerBeta)
        $Main_Tool_Icon.contextMenu.MenuItems.Add($Menu_AttachedProcesses)
        $Main_Tool_Icon.contextMenu.MenuItems.Add($Menu_Kill)
        $Main_Tool_Icon.contextMenu.MenuItems.Add($Menu_Exit)
    }
})

 



$Menu_Exit.add_Click({
    $Main_Tool_Icon.Visible = $false
Stop-Job -Name "Loop"
$global:balloon = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::None 
$balloon.BalloonTipText = 'RobloxBetaFix has closed!'
$balloon.BalloonTipTitle = "Goodbye!" 
$balloon.Visible = $true 
$balloon.ShowBalloonTip(7000)

    Stop-Process -Name FixBetaApp -Force

 })
 
 $Menu_Kill.add_Click({
    $roblox = Get-Process RobloxPlayerBeta -ErrorAction SilentlyContinue
    if ($roblox) {
            Stop-Process -Name RobloxPlayerBeta -Force
        }
 })
 

 $WhLoop = {
    $Key = "HKCU:\Software\ROBLOX Corporation\Environments\roblox-player"
    while ($true) {
       
    $roblox = Get-Process RobloxPlayerBeta -ErrorAction SilentlyContinue
    #Basically we are getting RobloxPlayerBeta and checking if its running, then if it starts to not respond we close the program
    if ($roblox) {
       
       
        if((get-process RobloxPlayerBeta).Responding){
         #Write-Output "Roblox Running Properly"
            }else{
            #Write-Output "Roblox Crash"
                Get-Process RobloxPlayerBeta|
                Sort-Object StartTime -Descending|
                Select-Object -Skip 1|
                Stop-Process
            #Stop-Process -Name RobloxPlayerBeta -Force
            }
        }
        $CurrentValue = (Get-ItemProperty -Path $Key -Name "LaunchExp").LaunchExp
        if ($CurrentValue -eq "InApp")
        {
            #Write-Output "Value is InApp."
            Set-ItemProperty -Path $Key -Name "LaunchExp" -Value "InBrowser"
        }
    
        Start-Sleep -Milliseconds 20
    }
    }
Start-Job -ScriptBlock $WhLoop -Name "Loop"



[System.GC]::Collect()

 

# Create an application context for it to all run within.
# This helps with responsiveness, especially when clicking Exit.
$appContext = New-Object System.Windows.Forms.ApplicationContext
[void][System.Windows.Forms.Application]::Run($appContext)
