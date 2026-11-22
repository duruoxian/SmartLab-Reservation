param(
    [string] $Python = 'C:\APP\SmartLab-Reservation\venv\Scripts\python.exe',
    [string] $QtRoot = 'C:\Qt',
    [string] $QtVersion = '6.11.1',
    [string] $MingwKit = 'mingw1310_64',
    [ValidateRange(1, 65535)] [int] $Port = 8765,
    [switch] $CreateAdmin,
    [switch] $BuildOnly
)
$ErrorActionPreference = 'Stop'

$backend = Join-Path $PSScriptRoot 'backend'
$client = Join-Path $PSScriptRoot 'client'
$build = Join-Path $PSScriptRoot 'build'
$qt = Join-Path $QtRoot "$QtVersion\mingw_64"
$tools = Join-Path $QtRoot 'Tools'
$cmake = Join-Path $tools 'CMake_64\bin\cmake.exe'
$ninja = Join-Path $tools 'Ninja\ninja.exe'
$gxx = Join-Path $tools "$MingwKit\bin\g++.exe"

foreach ($path in $Python, $cmake, $ninja, $gxx, $qt) {
    if (-not (Test-Path -LiteralPath $path)) { throw "Required tool not found: $path" }
}
$Python = (Resolve-Path -LiteralPath $Python).ProviderPath
$sha = [System.Security.Cryptography.SHA256]::Create()
try {
    $repoHash = $sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($PSScriptRoot))
} finally {
    $sha.Dispose()
}
$key = ([BitConverter]::ToString($repoHash) -replace '-', '').Substring(0, 16)
$scratch = Join-Path $env:TEMP "smartlab-qt-$key"
$qtSource = Join-Path $scratch 'source'
$qtBuild = Join-Path $scratch 'release'
[IO.Directory]::CreateDirectory($qtSource) | Out-Null
[IO.Directory]::CreateDirectory($build) | Out-Null
Copy-Item -LiteralPath (Join-Path $client 'CMakeLists.txt'), (Join-Path $client 'src'), (Join-Path $client 'qml') -Destination $qtSource -Recurse -Force
$oldPath = $env:Path
$oldPythonUtf8 = $env:PYTHONUTF8
$env:Path = "$qt\bin;$tools\$MingwKit\bin;$tools\Ninja;$oldPath"
$env:PYTHONUTF8 = '1'
try {
    & $Python -B -c 'import fastapi, uvicorn, sqlalchemy, jwt'
    if ($LASTEXITCODE -ne 0) { throw "Install backend dependencies from $backend\requirements.txt first." }

    & $cmake -S $qtSource -B $qtBuild -G Ninja "-DCMAKE_PREFIX_PATH=$qt" "-DCMAKE_MAKE_PROGRAM=$ninja" "-DCMAKE_CXX_COMPILER=$gxx" '-DCMAKE_BUILD_TYPE=Release'
    if ($LASTEXITCODE -ne 0) { throw 'CMake configuration failed.' }
    & $cmake --build $qtBuild
    if ($LASTEXITCODE -ne 0) { throw 'Qt client build failed.' }
    $executable = Join-Path $build 'SmartLab.exe'
    Copy-Item -LiteralPath (Join-Path $qtBuild 'SmartLab.exe') -Destination $executable -Force
    if ($BuildOnly) {
        Write-Output $executable
        return
    }

    Push-Location -LiteralPath $backend
    try {
        if ($CreateAdmin) {
            & $Python -B -m app.seed_admin
            if ($LASTEXITCODE -ne 0) { throw 'Administrator initialization failed.' }
        }
        & $Python -B -m app.dev --client $executable --port $Port
        if ($LASTEXITCODE -ne 0) { throw 'SmartLab stopped with an error.' }
    } finally {
        Pop-Location
    }
} finally {
    $env:Path = $oldPath
    $env:PYTHONUTF8 = $oldPythonUtf8
}
