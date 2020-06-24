# TODO(kdinghofer): This installer template still needs (probably a lot) of work
$metadata = [ordered]@{
    "description" = "";
    "dll" = ".dll";
    "lang" = "de-DE"
}
# Ensure admin priveleges:
# Start-Process powershell ... -Verb RunAs

$supportedArchitectures = [ordered]@{
    '0' = "x86";
    '6' = "ia64";
    '9' = "x64";
}
# $bytes = [System.Text.Encoding]::UTF8.GetBytes([System.IO.File]::ReadAllBytes("USIntGr.dll"))
$arch = $supportedArchitectures["$((Get-WmiObject -Class Win32_Processor).Architecture)"]
if ($arch -eq "") {
    Write-Error "Architecture is not supported."
} else {
    Write-Host "Architecture is supported: $arch" -ForegroundColor Green
}
# [System.Globalization.CultureInfo]::GetCultures("AllCultures") | where LCID -eq 00c0