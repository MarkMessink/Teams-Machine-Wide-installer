<#
.SYNOPSIS
    Installation Teams Machine-Wide Install
	Mark Messink 30-06-2022

.DESCRIPTION
 
.INPUTS
  None

.OUTPUTS
  Log file: inlog_Teams-Machine-Wide-Install.txt
  
.NOTES
  https://docs.microsoft.com/en-us/microsoftteams/msi-deployment#how-the-microsoft-teams-msi-file-works
  
.EXAMPLE
  .\Teams-Machine-Wide-installer.ps1

# DownloadLocations:
https://aka.ms/teams64bitmsi

#>

# Prevent teminating script on error
$ErrorActionPreference = 'Continue'

# Create logpath (if not exist)
$logpath = "C:\IntuneLogs"
If(!(test-path $logpath))
{
      New-Item -ItemType Directory -Force -Path $logpath
}

$logFile = "$logpath\pslog_Teams-Machine-Wide-Install.txt"

#Start logging
Start-Transcript $logFile -Append -Force

#Start script timer
$scripttimer = [system.diagnostics.stopwatch]::StartNew()

	$ExeFile = (Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath "Teams Installer\Teams.exe")
	$ExeFile
	
	if (-not(Test-Path -Path "$ExeFile" -PathType Leaf)) {
		Write-Output "-------------------------------------------------------------------"
		Write-Output "Download Teams from Microsoft"
		$downloadLocation = "https://aka.ms/teams64bitmsi"
		$downloadDestination = "$($env:TEMP)\TeamsSetup.msi"
		$webClient = New-Object System.Net.WebClient
		$webClient.DownloadFile($downloadLocation, $downloadDestination)
		Write-Output "-------------------------------------------------------------------"
		Write-Output "Teams Download"
		(Get-Item $downloadDestination).VersionInfo | FL FileName 
		Write-Output "-------------------------------------------------------------------"
		Write-Output "Install Teams Machine-Wide"
		$installProcess = Start-Process msiexec.exe -Wait -ArgumentList "/i $downloadDestination OPTIONS=noAutoStart=true ALLUSERS=1" -NoNewWindow -PassThru
		$installProcess.WaitForExit()
		} else {
		Write-Output "-------------------------------------------------------------------"
		Write-Output "Per machine Teams already exists. Installation skipped"
	}
		
	if (Test-Path -Path "$ExeFile" -PathType Leaf) {
	Write-Output "-------------------------------------------------------------------"
	Write-Output "Teams version information:"
	(Get-Item $ExeFile).VersionInfo | FL Productname, FileName, Productversion
	Write-Output "-------------------------------------------------------------------"
	} else {
		Write-Output "-------------------------------------------------------------------"
		Write-Output "File not found. Installation failed"
		Write-Output "-------------------------------------------------------------------"
	}

#Stop and display script timer
$scripttimer.Stop()
Write-Output "-------------------------------------------------------------------"
Write-Output "Script elapsed time in seconds:"
$scripttimer.elapsed.totalseconds
Write-Output "-------------------------------------------------------------------"

#Stop Logging
Stop-Transcript
