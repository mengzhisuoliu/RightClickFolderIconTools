@echo off
mode con:cols=50 lines=9

:: set the refresh delay (in seconds)
set "refresh-delay=2"

:: Specify the number of refresh cycles.
set "refresh-cycle=1"

echo.
echo    %W_%Refreshing folder ..%G_%
timeout %refresh-delay%
for /l %%N in (1,1,%refresh-cycle%) do (
	for /f "usebackq tokens=* delims=" %%F in ("%FI-UpdateList%") do (
		cls
		title  refreshing.. "%%~nxF"
		echo.
		echo    %W_%Refreshing ..%_%
		echo %ESC%%CC_%%%~nxF%ESC%%R_%
		call "%FI-Update%" /f %%F >nul 2>&1 &call |EXIT /B
	)
)

:: Cleanup temp list and make sure it's a .txt file
for %%D in ("%FI-UpdateList%") do if /i "%%~xD"==".txt" del "%FI-UpdateList%"
exit