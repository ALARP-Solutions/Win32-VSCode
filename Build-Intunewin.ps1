
$vers = Read-Host -Prompt "Enter VSCode Version"

## ------------------------------ ##
## Create Build Folder
## ------------------------------ ##

$buildpath = "$PSScriptRoot\Builds\"

If (-Not (Test-Path $buildpath)) {
    New-Item -Path "$buildpath" -Name "" -ItemType "directory" | Out-Null
}

## ------------------------------ ##
## Create Temp Folder
## ------------------------------ ##

$temppath = "$PSScriptRoot\temp"
If (Test-Path $temppath) {
    $Items = Get-ChildItem -LiteralPath "$temppath" -Recurse
    foreach ($Item in $Items) {
        $Item.Delete()
    }
    $Items = Get-Item -LiteralPath "$temppath"
    $Items.Delete($true)
}
New-Item -Path "$PSScriptRoot" -Name "temp" -ItemType "directory" | Out-Null

## ------------------------------ ##
## Copy Inputs into Temp Folder
## ------------------------------ ##

# Copy-item -Force -Recurse "$PSScriptRoot\Inputs\*" -Destination "$PSScriptRoot\temp"

$installcmd = 'VSCodeSetup-x64-' + $vers + '.exe /verysilent /norestart /mergetasks=!runcode' #/log="%temp%\VSCodeInstall.log"'
$installcmd | Out-File "$PSScriptRoot\temp\Install.cmd"

$uninstallcmd = '"C:\Program Files\Microsoft VS Code\unins000.exe" /verysilent /norestart'
$uninstallcmd | Out-File "$PSScriptRoot\temp\Uninstall.cmd"

## ------------------------------ ##
## Download VSCode
## ------------------------------ ##

$url = "https://update.code.visualstudio.com/$vers/win32-x64/stable"
$filepath = "$temppath\VSCodeSetup-x64-" + $vers + ".exe"

$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $filepath)

## ------------------------------ ##
## Build the Intunewin File
## ------------------------------ ##
$Testpath = "$buildpath\VSCodeSetup-x64-" + $vers + ".exe"
if (Test-Path $Testpath) {
    Remove-Item $Testpath
}

#$dest = (new-object system.io.directoryinfo $PSScriptRoot).parent.fullname
& "$PSScriptRoot\Microsoft Win32 Content Prep Tool\IntuneWinAppUtil.exe" -c "$temppath" -s "$filepath" -o "$buildpath"

## ------------------------------ ##
## Clean-Up
## ------------------------------ ##
If (Test-Path $temppath) {
    $Items = Get-ChildItem -LiteralPath "$temppath" -Recurse
    foreach ($Item in $Items) {
        $Item.Delete()
    }
    $Items = Get-Item -LiteralPath "$temppath"
    $Items.Delete($true)
}
