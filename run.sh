#!/bin/sh
# Builds (if needed) and runs the H8DIMGR Host GUI.
cd "$(dirname "$0")" || exit 1
exec dotnet run --project host/H8DImgGui -c Release "$@"
