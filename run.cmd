@echo off
rem Builds (if needed) and runs the H8DIMGR Host GUI.
cd /d "%~dp0"
dotnet run --project host\H8DImgGui -c Release %*
