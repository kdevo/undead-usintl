$BUILD_DIR = "build"

$MSKLC_BINARY_URL = "https://download.microsoft.com/download/1/1/8/118aedd2-152c-453f-bac9-5dd8fb310870/MSKLC.exe"
$MSKLC_BINARY = "msklc.exe.zip"

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
Set-Location $scriptDir

function Get-Msklc(
    [string] $Url = $MSKLC_BINARY_URL,
    [string] $Target = $MSKLC_BINARY
) {
    if (-Not (Test-Path $Target -PathType Leaf)) {
        Write-Output "File '$Target' does not exist. Attempt to download it."
        Invoke-WebRequest -Uri $Url -OutFile $Target 
    }

    $auth = Get-AuthenticodeSignature $Target
    $sig = $auth.SignerCertificate
    Write-Output $sig
    if ($auth.Status -ne "Valid" -or -not $sig.Subject.StartsWith("CN=Microsoft Corporation")) {
        Write-Error "Signature is not valid or not from Microsoft. Ensure file integrity!"
        Exit 9
    }
    Write-Verbose "Signature OK. Can securely continue with installation."
    Write-Host "Extracting Setup..."
    Expand-Archive $Target -Force -DestinationPath "extracted"

    Write-Host "Extracting MSI..."
    $msi = Resolve-Path "./extracted/MSKLC.msi"
    Start-Process -Wait "msiexec" "-a", "$msi", TARGETDIR="$(Get-Location)\msklc", "/qb"
}

function Clean(
    [switch] $Full,
    [string] $BuildDir = $BUILD_DIR
) {
    Remove-Item $BuildDir/*
    if ($Full) {
        # TODO(kdevo): Improve safety, refactor to variables
        Remove-Item "msklc/" -Recurse -Force
        Remove-Item "extracted/" -Recurse -Force
        Remove-Item $MSKLC_BINARY -Force
    }
}
function Invoke-Kbdutool(
    [string] $Architecture,
    [string] $Layout,
    [string] $Name,
    [string] $BuildDir = $BUILD_DIR
) {

    $Layout = Resolve-Path $Layout
    New-Item -Name $BuildDir -ItemType Directory -Force
    
    $architectures = [ordered]@{"x86" = "-x"; "x64" = "-m"; "ia64" = "-i"; "wow64" = "-o" }

    # TODO(kdevo): Add error handling here to properly detect .klc files:
    $nameInLayout = (Select-String "^KBD\s+([A-Z]{1,8})" -Path $Layout).Matches.Groups[1].Value
    Write-Host $nameInLayout
    Start-Process -NoNewWindow -Wait -PassThru -FilePath "./msklc/bin/i386/kbdutool.exe" -WorkingDirectory $BuildDir -ArgumentList "-v", "-w", $architectures[$Architecture], "-u", "$Layout" 
    Move-Item "build/$nameInLayout.dll" "build/$Name-$Architecture.dll"
}

function Compile([string]$Layout, [string]$Name, [string]$BuildDir = $BUILD_DIR) {
    foreach ($arch in "x86", "x64", "ia64") {
        Invoke-Kbdutool -Architecture $arch -Layout $Layout -Name $Name -BuildDir $BuildDir
    }
}

function Patch-KeyboardHeader() {
    $toPatch = "msklc/inc/kbd.h"
    Copy-Item -Path $toPatch -Destination "$toPatch.bak" -Force

    $regex = "(#define T3A _EQ)\(\s+CAPITAL\s+\)"
    $patched = (Get-Content $toPatch) -replace $regex, '$1( ESCAPE )'
    Set-Content -Path $toPatch -Value $patched -Force
}

function Unpatch-KeyboardHeader {
    $toPatch = "msklc/inc/kbd.h"
    Move-Item -Path "$toPatch.bak" -Destination "$toPatch" -Force
}

function Package([string] $Name, [string]$BuildDir = $BUILD_DIR) {
    # TODO(kdevo): Provide simple one-file installer PS script with binaries
}

function Install([string] $DLL, [string] $BuildDir = $BUILD_DIR) {
    $path = "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layouts\c0010409" 
    $dllDest = "%SystemRoot%\System32\$DLL"
    $productId = "{$(New-Guid)}".ToUpper()

    New-Item -Path $path -Force
    New-ItemProperty -Path $path -Name "Layout Text" -Value "United States-International ESC" -Force
    New-ItemProperty -Path $path -Name "Layout File" -Value "$DLL" -Force
    New-ItemProperty -Path $path -Name "Layout Product Code" -Value "$($productId)"  -Force
    New-ItemProperty -Path $path -Name "Layout Id" -Value "00c0" -Force
    New-ItemProperty -Path $path -Name "Layout Display Name" -Value "@$($dllDest -replace '\\', '\\'),-1000" -Force
    New-ItemProperty -Path $path -Name "Custom Language Name" -Value "English (United States)" -Force
    New-ItemProperty -Path $path -Name "Custom Language Display Name" -Value "@$($dllDest -replace '\\', '\\'),-1100" -Force

    $expandedDllDest = [System.Environment]::ExpandEnvironmentVariables($dllDest)
    Copy-Item -Path "$BuildDir\$DLL" -Destination $expandedDllDest
}

Clean -Full
Get-Msklc
Patch-KeyboardHeader
Compile "layouts\usintl-undead\usintl.klc" "usintl-nodead"
Unpatch-KeyboardHeader
Install -DLL "usintl-nodead-x64.dll"