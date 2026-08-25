@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"

set "INTERACTIVE=0"
if "%~1"=="" set "INTERACTIVE=1"

set "TARGET="
if not "%~1"=="" set "TARGET=%~f1"
if not defined TARGET if exist "%~dp0MJDFv1.exe" set "TARGET=%~dp0MJDFv1.exe"
if not defined TARGET if exist "%~dp0dist\MJDFv1.exe" set "TARGET=%~dp0dist\MJDFv1.exe"

set "OUT=%~dp0SHA256SUMS.txt"
set "TMP=%TEMP%\mjdfv1-sha-%RANDOM%-%RANDOM%.txt"
if exist "%TMP%" del /f /q "%TMP%" >nul 2>&1

echo ================================================================
echo MJ DNS FILTER v1 - SHA-256 generator
echo ================================================================
echo.

if not defined TARGET goto :NOT_FOUND
if not exist "%TARGET%" goto :NOT_FOUND

for %%F in ("%TARGET%") do set "BASENAME=%%~nxF"
if /I not "%BASENAME%"=="MJDFv1.exe" goto :WRONG_NAME

echo Input:  %TARGET%
echo Output: %OUT%
echo.

set "HASH="
where powershell.exe >nul 2>&1
if not errorlevel 1 (
    set "MJDF_HASH_TARGET=%TARGET%"
    powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; (Get-FileHash -LiteralPath $env:MJDF_HASH_TARGET -Algorithm SHA256).Hash.ToLowerInvariant()" > "%TMP%" 2>nul
    if not errorlevel 1 set /p "HASH="<"%TMP%"
)

if defined HASH goto :HAVE_HASH

rem PowerShell failed or was unavailable. certutil is an inbox Windows fallback.
set "HASH="
where certutil.exe >nul 2>&1
if errorlevel 1 goto :HASH_FAILED
certutil.exe -hashfile "%TARGET%" SHA256 > "%TMP%" 2>nul
if errorlevel 1 goto :HASH_FAILED
for /f "usebackq skip=1 tokens=* delims=" %%H in ("%TMP%") do if not defined HASH set "HASH=%%H"
if not defined HASH goto :HASH_FAILED
set "HASH=%HASH: =%"

:HAVE_HASH
if not defined HASH goto :HASH_FAILED
> "%OUT%" echo %HASH% *MJDFv1.exe
if errorlevel 1 goto :WRITE_FAILED

echo [OK] SHA-256 generated successfully.
echo.
echo %HASH%  MJDFv1.exe
echo.
echo Created:
echo   %OUT%
echo.
echo GitHub Release v1 assets:
echo   MJDFv1.exe
echo   SHA256SUMS.txt
echo   generate-SHA256-MJDFv1.bat
echo   verify-SHA256-MJDFv1.bat
echo.
if exist "%TMP%" del /f /q "%TMP%" >nul 2>&1
if "%INTERACTIVE%"=="1" pause
endlocal & exit /b 0

:NOT_FOUND
echo [ERROR] MJDFv1.exe was not found.
echo.
echo Supported use:
echo   1. Put this BAT beside MJDFv1.exe and double-click it.
echo   2. Put this BAT in the repository root with dist\MJDFv1.exe and double-click it.
echo   3. Drag MJDFv1.exe onto this BAT.
echo   4. Run: generate-SHA256-MJDFv1.bat "C:\path\to\MJDFv1.exe"
echo.
if "%INTERACTIVE%"=="1" pause
endlocal & exit /b 2

:WRONG_NAME
echo [ERROR] The public v1 release binary must be named exactly MJDFv1.exe.
echo Received: %BASENAME%
echo.
echo Use the official release binary named exactly MJDFv1.exe.
echo.
if "%INTERACTIVE%"=="1" pause
endlocal & exit /b 5

:HASH_FAILED
echo [ERROR] SHA-256 calculation failed with both PowerShell and certutil.
echo Verify that MJDFv1.exe is readable and try again.
echo.
if exist "%TMP%" del /f /q "%TMP%" >nul 2>&1
if "%INTERACTIVE%"=="1" pause
endlocal & exit /b 3

:WRITE_FAILED
echo [ERROR] Could not write:
echo   %OUT%
echo Check folder permissions and try again.
echo.
if exist "%TMP%" del /f /q "%TMP%" >nul 2>&1
if "%INTERACTIVE%"=="1" pause
endlocal & exit /b 4
