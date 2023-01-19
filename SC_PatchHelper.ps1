If(-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}


$rootPath = Read-Host -Prompt "Enter the path where the Library folder is located. If unsure, run RSI Launcher > Settings > Library Folder (e.g. F:\RSI)"

$version = Read-Host -Prompt "Enter the version you want to modify (e.g. LIVE, PTU, EPTU)"

switch ($version) {
    "LIVE" {
        $sourcebindings = Get-ChildItem -Path "$rootPath\StarCitizen\LIVE" -Directory -Recurse | Where-Object {$_.Name -eq "Mappings"}
        $sourcefolder = Get-ChildItem -Path "$rootPath\StarCitizen\LIVE" -Directory -Recurse | Where-Object {$_.Name -eq "USER"}
    }
    "PTU" {
        $sourcebindings = Get-ChildItem -Path "$rootPath\StarCitizen\PTU" -Directory -Recurse | Where-Object {$_.Name -eq "Mappings"}
        $sourcefolder = Get-ChildItem -Path "$rootPath\StarCitizen\PTU" -Directory -Recurse | Where-Object {$_.Name -eq "USER"}
    }
    "EPTU" {
        $sourcebindings = Get-ChildItem -Path "$rootPath\StarCitizen\EPTU" -Directory -Recurse | Where-Object {$_.Name -eq "Mappings"}
        $sourcefolder = Get-ChildItem -Path "$rootPath\StarCitizen\EPTU" -Directory -Recurse | Where-Object {$_.Name -eq "USER"}
    }
    default {
        Write-Host "Invalid input. Please enter a valid version (e.g. LIVE, PTU, EPTU)"
        exit
    }
}

if ($sourcebindings -eq $null -or $sourcefolder -eq $null) {
    $confirmation = Read-Host "Mappings or USER folder not found. Press 'Y' to exit the script"
    if ($confirmation -eq 'Y') {
    exit
    }
}

$backupfolder = "$env:localappdata\Star Citizen Backup $version $((Get-Date).ToString("MMddyyyy"))"

if ($confirm -eq 'yes') {
    # Script code
    if (!(Test-Path -Path $backupfolder)) {
        New-Item -ItemType directory -Path $backupfolder
    }
    Copy-Item -Path $sourcebindings.FullName -Destination $backupfolder -Recurse
}

$shadersfolder = "$env:localappdata\Star Citizen"

$confirm = Read-Host -Prompt "Are you sure you want to run this script? (yes/no)"
if ($confirm -eq 'yes') {
    # Script code
} else {
    Write-Host "Script execution cancelled"
    exit
}

Copy-Item -Path $sourcebindings.FullName -Destination $backupfolder -Recurse

if (Test-Path $backupfolder -PathType Container) {
    # folder exists, continue with the script
} else {
    Write-Host "Folder $backupfolder does not exist"
    # stop the script or take other necessary actions
}

Remove-Item -Path $sourcefolder.FullName -Recurse -Force

Remove-Item -Path $shadersfolder -Recurse -Force

$response = Read-Host -Prompt "Please launch Star Citizen. Once fully loaded and at the menu screen, quit the game and continue the script. Type 'done' when ready to move to the next step"
while ($response -ne 'done') {
    $response = Read-Host -Prompt "Please launch Star Citizen and then close the game after launch and type 'done' below"
}

Copy-Item -Path $backupfolder\* -Destination $sourcebindings.FullName -Recurse


Write-Host "Task completed successfully. Don't forget to load your custom controls using in-game options menu or the in-game console with the command 'pp_rebindkeys <xmlpath>' to load the xml.  Press 'Y' to close the script."
$confirmation = Read-Host
if ($confirmation -eq 'Y') {
    exit
}


