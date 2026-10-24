param([Parameter(Mandatory=$true)][string]$Version)
$ErrorActionPreference = 'Stop'
$bundle = 'build\windows\x64\runner\Release'
if (!(Test-Path "$bundle\readtrack.exe")) { throw 'Windows build is missing' }
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vs = & $vswhere -latest -products '*' -property installationPath
$crt = Get-ChildItem "$vs\VC\Redist\MSVC\*\x64\Microsoft.VC*.CRT" -Directory | Sort-Object FullName -Descending | Select-Object -First 1
if (!$crt) { throw 'Visual C++ redistributable DLLs not found' }
foreach ($dll in @('msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll')) {
    Copy-Item (Join-Path $crt.FullName $dll) $bundle
}
New-Item -ItemType Directory -Force dist, build\prerequisites | Out-Null
Invoke-WebRequest 'https://go.microsoft.com/fwlink/p/?LinkId=2124703' -OutFile build\prerequisites\MicrosoftEdgeWebview2Setup.exe
$signature = Get-AuthenticodeSignature build\prerequisites\MicrosoftEdgeWebview2Setup.exe
if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch 'Microsoft Corporation') { throw 'WebView2 bootstrapper signature is not valid' }
Compress-Archive -Path "$bundle\*" -DestinationPath "dist\readtrack-$Version-windows-x64.zip" -Force
& "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe" "/DAppVersion=$Version" packaging\windows\readtrack.iss
if ($LASTEXITCODE -ne 0) { throw 'Inno Setup failed' }
