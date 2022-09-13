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
    $CurrentValue = (Get-ItemProperty -Path $Key -Name "LaunchExp").LaunchExp
    if ($CurrentValue -eq "InApp")
    {
        #Write-Output "Value is InApp."
        Set-ItemProperty -Path $Key -Name "LaunchExp" -Value "InBrowser"
    }

    Start-Sleep -Milliseconds 50
}
