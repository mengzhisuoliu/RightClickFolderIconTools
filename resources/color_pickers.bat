@echo off
mode con: cols=37 lines=3
echo.
echo  %I_%%CC_% Opening color pickers... %_%
if exist "%SaveSelectedColor%" del /q "%SaveSelectedColor%"
set pscolorpickers="& {Add-Type -AssemblyName System.Windows.Forms; $ColorDialog = New-Object System.Windows.Forms.ColorDialog; $ColorDialog.FullOpen = $true; if ($ColorDialog.ShowDialog() -eq 'OK') {Write-Output $ColorDialog.Color} }"
set "line="&set "RGB="
for /f "tokens=1,2 delims=:" %%C in ('powershell -NoProfile -ExecutionPolicy Bypass -Command %pscolorpickers%') do (
	set "var=%%C"
	set "val=%%D"
	call :collectRGB
)
echo RGB: "%RGB%"
echo set "FolderName-Font-Color=rgba(%RGB:"=%,0.9)">>"%SaveSelectedColor%"
EXIT

:collectRGB
set "val=%val: =%"
set /a line+=1
if %line% GEQ 4 exit /b
if %line%==1 set "RGB=%val%"&exit /b
set RGB=%RGB%,%val%
exit /b