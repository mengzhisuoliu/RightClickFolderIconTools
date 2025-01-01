@echo off
chcp 65001 >nul
for %%F in ("%cd%") do set "foldername=%%~nxF"
title Custom folder name for "%FolderName%"
echo.
echo.
echo                  %W_%%I_%     Custom Folder Name     %_%       
echo.
echo %TAB%Folder Name:%ESC%%YY_%%FolderName%%ESC%
echo %TAB%Template   :%ESC%%CC_%%Templatename%%ESC%
echo.
echo.
echo %_% • %G_%%G_%Press "%C_%O%G_%" and hit Enter to %C_%open%G_% the file selection dialog.%_%
echo %_% • %G_%%G_%Press "%C_%C%G_%" and hit  Enter to  open the %C_%Collections%G_%  folder.%_%
echo %_% • %G_%%G_%Press  "%C_%F%G_%"  and  hit  Enter  to  select  the  %_%Font  color%G_%.%_%
echo %_% • %G_%You can  also %PP_%drag and  drop%_%%G_% an %C_%image%G_%  into  this  window.%_%
echo %_% • %G_%Leave it  empty  to  skip and  use  the default  settings.%_%
echo.
if exist "%cfn1%" del /q "%cfn1%"

:input
set "too="
set "InputFolderName=_0"
set "InputLogo=_0"
set "custom-FolderName-HaveTheLogo="
echo %W_% ► %G_%Enter a folder name or an image file path:
set /p "InputFolderName=%W_%  %_%%C_% "
set "InputFolderName=%InputFolderName:"=%"

if /i "%InputFolderName%"=="o" set "InitDir=%cd%"&call :fileselector
if /i "%InputFolderName%"=="c" set "InitDir=%CollectionsFolder%"&call :fileselector
if /i "%InputFolderName%"=="f" set "InitDir=%CollectionsFolder%"&goto colorpickers

if /i "%InputFolderName%"=="_0" (
	echo   %ESC%%YY_%%Foldername%%ESC%%_%
	echo set "custom-FolderName=No">>"%cfn1%"
	goto exit
)
if /i "%InputFolderName%"=="." goto empty
if /i "%InputFolderName%"==" " goto empty
if /i "%InputFolderName%"=="_" goto empty

if exist "%InputFolderName%" for %%I in ("%InputFolderName%") do (
	for %%X in (%ImageSupport%) do if "%%X"=="%%~xI" (
		echo set "Logo=%%~fI">>"%cfn1%"
		echo set "LogoName=%%~nxI">>"%cfn1%"
		echo set "use-Logo-instead-FolderName=Yes">>"%cfn1%"
		echo set "custom-FolderName-HaveTheLogo=Yes">>"%cfn1%"
		goto exit
	)
)
echo set "foldername=%InputFolderName%">>"%cfn1%"
echo set "display-FolderName=Yes">>"%cfn1%"
echo set "use-Logo-instead-FolderName=No">>"%cfn1%"
goto exit

:empty
echo set "display-FolderName=no">>"%cfn1%"
echo set "use-Logo-instead-FolderName=no">>"%cfn1%"
goto exit


:fileselector
set "SaveSelectedFile=%RCFI%\resources\selected_file.txt"
for /f "tokens=1-12 delims=," %%A in ("%ImageSupport%") do (
    set fileFilter=*%%A;*%%B;*%%C;*%%D;*%%E;*%%F;*%%G;*%%H;*%%I;*%%J;*%%K;*%%L
)
set "fileFilter=Image Files (*.jpg, *.png, *.ico, ...)|%fileFilter%"
set "OpenFileSelector=Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.OpenFileDialog; $f.InitialDirectory = '%InitDir%'; $fileDialog.RestoreDirectory = $true; $f.Filter = '%fileFilter%'; $f.ShowDialog() | Out-Null; $f.FileName; exit"

start /MIN /WAIT "" "%RCFI%\resources\File_Selector.bat"

for /f "usebackq tokens=* delims=" %%F in ("%SaveSelectedFile%") do set "SelectedFile=%%~fF"&set "FileName=%%~nxF"
del /q "%SaveSelectedFile%" >nul
if not exist "%SelectedFile%" echo    %G_%%I_% No file selected. %_%&goto input%too%
set "InputFolderName%too%=%SelectedFile%"
echo     %_%"%C_%%FileName%%_%"
echo.
exit /b

:colorpickers
set "SaveSelectedColor=%RCFI%\resources\selected_color.txt"
start /MIN /WAIT "" "%RCFI%\resources\color_pickers.bat"
if not exist "%SaveSelectedColor%" echo    %G_%%I_% No color selected. %_%&goto input%too%
for /f "usebackq tokens=* delims=" %%F in ("%SaveSelectedColor%") do %%F
del /q "%SaveSelectedColor%"
echo set "FolderName-Font-Color=%FolderName-Font-Color%">>"%cfn1%"
echo    %G_%Font color:%_%%FolderName-Font-Color%%_%
echo.
goto input%too%

:exit
if /i not "%multi-FolderName%"=="yes" exit
goto input2

:input2
set "too=2"
set "InputFolderName2="
echo.
echo %W_% ► %G_%Enter the second folder name, or leave it empty to skip:
set /p "InputFolderName2=%W_%  %_%%C_% "
if /i "%InputFolderName2%"=="o" set "InitDir=%cd%"&call :fileselector
if /i "%InputFolderName2%"=="c" set "InitDir=%CollectionsFolder%"&call :fileselector
if /i "%InputFolderName2%"=="f" set "InitDir=%CollectionsFolder%"&goto colorpickers
type nul "%cfn2%"
set InputFolderName2=%InputFolderName2:"=%
if defined InputFolderName2 echo "%InputFolderName2%">>"%cfn2%"
exit