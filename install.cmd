@echo off
setlocal
set "POWERSHELL=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%POWERSHELL%" set "POWERSHELL=powershell.exe"
"%POWERSHELL%" -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "irm https://aim.tino.vn/install.ps1 | iex"
exit /b %ERRORLEVEL%
