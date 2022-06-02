Param(
    [Parameter(Mandatory=$false)]
    [Switch]$Testing
)

$vers = '1.67.2' #Read-Host -Prompt "Enter VSCode Version"

## ------------------------------ ##
## Create Build Folder
## ------------------------------ ##
if ($Testing.IsPresent) {
    $buildpath = "$PSScriptRoot\TestingFolder\"
} else {
    $buildpath = "$PSScriptRoot\Builds\"
}
    
    If (-Not (Test-Path $buildpath)) {
        New-Item $buildpath -ItemType "directory" | Out-Null
    }
## ------------------------------ ##
## Create Temp Folder
## ------------------------------ ##
$tempfolder = "Temp"
if ($Testing.IsPresent) {
    $temppath = "$PSScriptRoot\TestingFolder\$tempfolder"
} else {
    $temppath = "$PSScriptRoot\$tempfolder"
}

If (Test-Path $temppath) {
    $Items = Get-ChildItem -LiteralPath $temppath -Recurse
    foreach ($Item in $Items) {
        $Item.Delete()
    }
    $Items = Get-Item -LiteralPath $temppath
    $Items.Delete($true)
}
New-Item $temppath -ItemType "directory" | Out-Null

## ------------------------------ ##
## Copy Inputs into Temp Folder
## ------------------------------ ##

$installcmd = @"
@echo off
start "" "%~dp0VSCodeSetup-x64-$vers.exe" /verysilent /norestart /mergetasks=!runcode
timeout /T 20 /NOBREAK
"@
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines("$temppath\Install.cmd", $installcmd, $Utf8NoBomEncoding)

$uninstallcmd = '"C:\Program Files\Microsoft VS Code\unins000.exe" /verysilent /norestart'
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines("$temppath\Uninstall.cmd", $uninstallcmd, $Utf8NoBomEncoding)

## ------------------------------ ##
## Download VSCode
## ------------------------------ ##

$url = "https://update.code.visualstudio.com/$vers/win32-x64/stable"
$filepath = "$temppath\VSCodeSetup-x64-$vers.exe"

$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $filepath)

## ------------------------------ ##
## Build the Intunewin File
## ------------------------------ ##
if (-Not ($Testing.IsPresent)) {
    $Testpath = "$buildpath\VSCodeSetup-x64-$vers.intunewin"
    if (Test-Path $Testpath) {
        Remove-Item $Testpath
    }
    
    & "$PSScriptRoot\Microsoft Win32 Content Prep Tool\IntuneWinAppUtil.exe" -c "$temppath" -s "$filepath" -o "$buildpath"
}

## ------------------------------ ##
## Build the Detection Script
## ------------------------------ ##
$DSpath = "$buildpath\DetectionScript.$vers.ps1"
if (Test-Path $DSpath) {
    Remove-Item $DSpath
}

$detectionScript = @"
`$FileVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("C:\Program Files\Microsoft VS Code\Code.exe").FileVersion
#The below line trims the spaces before and after the version name
`$FileVersion = `$FileVersion.Trim();
if ([System.Version]`$FileVersion -ge [System.Version]'$vers') {
    #Write the version to STDOUT by default
    `$FileVersion
    exit 0
}
else {
    #Exit with non-zero failure code
    exit 1
}
"@
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines($DSpath, $detectionScript, $Utf8NoBomEncoding)

## ------------------------------ ##
## Clean-Up
## ------------------------------ ##
if (-Not ($Testing.IsPresent)) {
    If (Test-Path $temppath) {
        $Items = Get-ChildItem -LiteralPath "$temppath" -Recurse
        foreach ($Item in $Items) {
            $Item.Delete()
        }
        $Items = Get-Item -LiteralPath "$temppath"
        $Items.Delete($true)
    }
}
