@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"

set "SUMS=%~dp0SHA256SUMS.txt"
if not "%~1"=="" set "SUMS=%~f1"

if not exist "%SUMS%" (
    echo [ERROR] Checksum file not found: %SUMS%
    exit /b 2
)

where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo [ERROR] PowerShell is required to verify SHA-256 hashes.
    exit /b 1
)

echo ================================================================
echo MJ DNS FILTER v1 - SHA-256 verification
echo Checksum file: %SUMS%
echo ================================================================
echo.

set "MJDF_SUMS=%SUMS%"
set "MJDF_VERIFY_ROOT=%~dp0"
powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop'; $ok=$true; $root=$env:MJDF_VERIFY_ROOT; Get-Content -LiteralPath $env:MJDF_SUMS | ForEach-Object { $line=$_.Trim(); if(-not $line -or $line.StartsWith('#')){ return }; if($line -notmatch '^([0-9a-fA-F]{64})\s+\*?(.*)$'){ Write-Host ('[BAD FORMAT] '+$line) -ForegroundColor Red; $ok=$false; return }; $expected=$matches[1].ToLowerInvariant(); $name=$matches[2]; $file=Join-Path $root $name; if(-not (Test-Path -LiteralPath $file)){ $dist=Join-Path (Join-Path $root 'dist') $name; if(Test-Path -LiteralPath $dist){ $file=$dist } }; if(-not (Test-Path -LiteralPath $file)){ Write-Host ('[MISSING] '+$name) -ForegroundColor Red; $ok=$false; return }; $actual=(Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant(); if($actual -eq $expected){ Write-Host ('[OK] '+$name) -ForegroundColor Green } else { Write-Host ('[FAIL] '+$name) -ForegroundColor Red; Write-Host (' expected '+$expected); Write-Host (' actual   '+$actual); $ok=$false } }; if(-not $ok){ exit 1 }"

if errorlevel 1 (
    echo.
    echo VERIFICATION FAILED
    exit /b 1
)

echo.
echo All listed files verified successfully.
endlocal & exit /b 0
