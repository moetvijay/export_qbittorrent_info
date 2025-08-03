@echo off
setlocal enabledelayedexpansion

:: Fail-safe: Exit if required parameters are missing
if "%~1"=="" (
  echo [ERROR] Missing parameters. This script should only be called by qBittorrent.
  exit /b
)

:: Inputs from qBittorrent
set "TORRENT_NAME=%~1"
set "TORRENT_DIR=%~2"
set "TORRENT_HASH=%~3"
set "TORRENT_FILE=%~4"

:: Determine scope to walk through
if exist "%TORRENT_FILE%\" (
  set "TARGET_PATH=%TORRENT_FILE%"
) else (
  set "TARGET_PATH=%TORRENT_FILE%"
)

:: Where to save JSON
set "OUTFILE=%TORRENT_DIR%\%TORRENT_NAME%-info.json"

:: Init counters
set /a FILE_COUNT=0
set /a TOTAL_SIZE=0

:: Begin writing JSON
(
  echo {
  echo   "torrent_name": "%TORRENT_NAME%",
  echo   "info_hash": "%TORRENT_HASH%",
) > "%OUTFILE%"

:: Start files array
echo   "files": [>> "%OUTFILE%"

set "FIRST=1"
if exist "%TARGET_PATH%\" (
  for /r "%TARGET_PATH%" %%F in (*) do (
    set /a FILE_COUNT+=1
    set /a TOTAL_SIZE+=%%~zF

    for /f %%A in ('powershell -nologo -command "[math]::Round((%%~zF / 1KB),2)"') do set "H_SIZE=%%A KB"
    if %%~zF GEQ 1048576 (
      for /f %%B in ('powershell -nologo -command "[math]::Round((%%~zF / 1MB),2)"') do set "H_SIZE=%%B MB"
    )
    if %%~zF GEQ 1073741824 (
      for /f %%C in ('powershell -nologo -command "[math]::Round((%%~zF / 1GB),2)"') do set "H_SIZE=%%C GB"
    )

    if not "!FIRST!"=="1" echo   ,>> "%OUTFILE%"
    echo     {>> "%OUTFILE%"
    echo       "path": "%%~fF",>> "%OUTFILE%"
    echo       "name": "%%~nxF",>> "%OUTFILE%"
    echo       "extension": "%%~xF">> "%OUTFILE%"
    echo       "size": "!H_SIZE!",>> "%OUTFILE%"
    echo       "size_bytes": %%~zF,>> "%OUTFILE%"
    echo     }>> "%OUTFILE%"
    set "FIRST=0"
  )
) else (
  if exist "%TARGET_PATH%" (
    set /a FILE_COUNT=1
    set /a TOTAL_SIZE=%~z4

    for /f %%A in ('powershell -nologo -command "[math]::Round((%~z4 / 1KB),2)"') do set "H_SIZE=%%A KB"
    if %~z4 GEQ 1048576 (
      for /f %%B in ('powershell -nologo -command "[math]::Round((%~z4 / 1MB),2)"') do set "H_SIZE=%%B MB"
    )
    if %~z4 GEQ 1073741824 (
      for /f %%C in ('powershell -nologo -command "[math]::Round((%~z4 / 1GB),2)"') do set "H_SIZE=%%C GB"
    )

    echo     {>> "%OUTFILE%"
    echo       "path": "%TARGET_PATH%",>> "%OUTFILE%"
    echo       "name": "%~nx4",>> "%OUTFILE%"
    echo       "extension": "%~x4">> "%OUTFILE%"
    echo       "size": "!H_SIZE!",>> "%OUTFILE%"
    echo       "size_bytes": %~z4,>> "%OUTFILE%"
    echo     }>> "%OUTFILE%"
  )
)

:: Format total size
set "TOTAL_HSIZE="
for /f %%A in ('powershell -nologo -command "[math]::Round((!TOTAL_SIZE! / 1KB),2)"') do set "TOTAL_HSIZE=%%A KB"
if !TOTAL_SIZE! GEQ 1048576 (
  for /f %%B in ('powershell -nologo -command "[math]::Round((!TOTAL_SIZE! / 1MB),2)"') do set "TOTAL_HSIZE=%%B MB"
)
if !TOTAL_SIZE! GEQ 1073741824 (
  for /f %%C in ('powershell -nologo -command "[math]::Round((!TOTAL_SIZE! / 1GB),2)"') do set "TOTAL_HSIZE=%%C GB"
)

:: Close files array and add summary fields
(
  echo   ],
  echo   "file_count": !FILE_COUNT!,
  echo   "total_size": !TOTAL_SIZE!,
  echo   "human_readable_total_size": "!TOTAL_HSIZE!"
  echo }
)>> "%OUTFILE%"
