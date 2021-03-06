# This script takes care of packaging the build artifacts that will go in the
# release zipfile

$env:PATH += ";C:\msys64\usr\bin\";

curl.exe -sL https://raw.githubusercontent.com/ethereumproject/janus/master/get-windows.sh | bash
$env:PATH += ";./janusbin"
$env:VERSION_BASE = "$(janus.exe version -format='v%M.%m.x')"
$env:VERSION = "$(janus.exe version -format='v%M.%m.%P-%C-%S')"

echo "Version base: $env:VERSION_BASE"
echo "Version: $env:VERSION"

nuget install secure-file -ExcludeVersion
secure-file\tools\secure-file -decrypt .ci\janus\gcloud-appveyor.json.enc -secret "$($Env:GCP_PASSWD)" -out .ci\.gcloud.json

$SRC_DIR = $PWD.Path
$STAGE = [System.Guid]::NewGuid().ToString()

Set-Location $ENV:Temp
New-Item -Type Directory -Name $STAGE
Set-Location $STAGE

mkdir $SRC_DIR\janus
$ZIP = "$SRC_DIR\janus\$($Env:CRATE_NAME)-$($Env:VERSION)-$($Env:TARGET).zip"

# TODO Update this to package the right artifacts
Copy-Item "$SRC_DIR\target\$($Env:TARGET)\release\svmdev.exe" '.\'

7z a "$ZIP" *

Remove-Item *.* -Force
Set-Location ..
Remove-Item $STAGE
Set-Location $SRC_DIR
