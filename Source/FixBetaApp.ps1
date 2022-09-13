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



Add-Type -AssemblyName System.Windows.Forms 
$global:balloon = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::None 
$balloon.BalloonTipText = 'RobloxBetaFix has Loaded!'
$balloon.BalloonTipTitle = "Welcome!" 
$balloon.Visible = $true 
$balloon.ShowBalloonTip(7000)


$Key = "HKCU:\Software\ROBLOX Corporation\Environments\roblox-player"
while ($true)
{

$roblox = Get-Process RobloxPlayerBeta -ErrorAction SilentlyContinue
#Basically we are getting RobloxPlayerBeta and checking if its running, then if it starts to not respond we close the program
if ($roblox) {
    if((get-process RobloxPlayerBeta).Responding){
     #Write-Output "Roblox Running Properly"
    }else{
      #Write-Output "Roblox Crash"
        Stop-Process -Name RobloxPlayerBeta -Force
    }
}
    $CurrentValue = (Get-ItemProperty -Path $Key -Name "LaunchExp").LaunchExp
    if ($CurrentValue -eq "InApp")
    {
        #Write-Output "Value is InApp."
        Set-ItemProperty -Path $Key -Name "LaunchExp" -Value "InBrowser"
    }

    Start-Sleep -Milliseconds 50
}
