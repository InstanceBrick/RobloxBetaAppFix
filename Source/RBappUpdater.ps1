# Check for multiple instances of the current program (stops errors/overlapping code)
function numInstances([string]$process)
{
    @(get-process -ea silentlycontinue $process).count
}
if ((numInstances FixBetaApp) -gt 0) {
    Stop-Process -Name FixBetaApp -Force
}

if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript")
{ # Powershell script
	$ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}
else
{ # PS2EXE compiled script
	$ScriptPath = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0])
}


if (Test-Path -Path $ScriptPath/FixBetaApp.exe) {
Remove-Item -Path $ScriptPath/FixBetaApp.exe
}

$url = "https://github.com/InstanceBrick/RobloxBetaAppFix/raw/main/FixBetaApp.exe"
$outpath = "$ScriptPath/FixBetaApp.exe"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $outpath)

$args = @("Comma","Separated","Arguments")
Start-Process -Filepath "$ScriptPath/FixBetaApp.exe" -ArgumentList $args