:: Template-Version=v1.3
:: 2024-06-22 Fixed: Star image rendering in folder icon even without a ".nfo" file.
:: 2024-06-24 Added: Global config to override template settings using RCFI.template.ini.
:: 2024-12-23 Added: Option to customize folder names.


::                Template Info
::========================================================
::`  Image template by 90scomics.com
::`  Convert and Edit using ImageMagick.
::` ------------------------------------------------------


::                Template Config
::========================================================
set "use-GlobalConfig=yes"
set "custom-FolderName=no"

::--------- Label --------------------------
set "display-FolderName=yes"
set "FolderNameShort-characters-limit=10"
set "FolderNameLong-characters-limit=40"
set "FolderName-Center=Auto"
set "FolderName-Font-Color=rgba(255,255,255,0.9)"

::--------- Movie Info ---------------------
set "display-movieinfo=yes"
set "show-Rating=yes"
set "preferred-rating=imdb"
set "show-Genre=yes"
set "genre-characters-limit=26"

::--------- Additional Art -----------------
set "use-Logo-instead-FolderName=yes"
set "display-clearArt=yes"
::========================================================


::                Images Source
::========================================================
set "foldervertical-side=%rcfi%\images\foldervertical-side.png"
set "foldervertical-sidefx=%rcfi%\images\foldervertical-sidefx.png"
set "foldervertical-sideshadow=%rcfi%\images\foldervertical-sideshadow.png"
set "foldervertical-main=%rcfi%\images\foldervertical-main.png"
set "foldervertical-mainfx=%rcfi%\images\foldervertical-mainfx.png"
set "star-image=%rcfi%\images\star.png"
set "canvas=%rcfi%\images\- canvas.png"
::========================================================
setlocal
chcp 65001 >nul
call :LAYER-BASE
call :LAYER-RATING
call :LAYER-GENRE
call :LAYER-LOGO
call :LAYER-CLEARART
call :LAYER-FOLDER_NAME

 "%Converter%"              ^
  %LAYER-BACKGROUND%         ^
  %LAYER-POSTER-SIDE%        ^
  %LAYER-FOLDER-NAME-SHORT%  ^
  %LAYER-FOLDER-NAME-LONG%   ^
  %LAYER-LOGO-IMAGE%         ^
  %LAYER-POSTER-SIDE-SHADOW% ^
  %LAYER-POSTER-MAIN%        ^
  %LAYER-CLEARART-IMAGE%     ^
  %LAYER-STAR-IMAGE%         ^
  %LAYER-RATING%             ^
  %LAYER-GENRE%              ^
  %LAYER-ICON-SIZE%          ^
 "%OutputFile%"
endlocal
exit /b



:::::::::::::::::::::::::::   CODE START   ::::::::::::::::::::::::::::::::

:LAYER-BASE
if /i "%use-GlobalConfig%"=="yes" (
	for /f "usebackq tokens=1,2 delims==" %%A in ("%RCFI.templates.ini%") do (
		if /i not "%%B"=="" if /i not %%B EQU ^" %%A=%%B
	)
)

set "cfn1=%RCFI%\resources\custom_foldername.txt"
if /i "%custom-FolderName%"=="yes" (
	start /WAIT "" "%RCFI%\resources\custom_foldername.bat"
	if exist "%cfn1%" (
		for /f "usebackq tokens=* delims=" %%C in ("%cfn1%") do %%C
		del /q "%cfn1%"
	)
)

set LAYER-BACKGROUND= ( ^
	"%canvas%" ^
	-scale 512x512! ^
	-background none ^
	-extent 512x512 ) -compose Over

set LAYER-POSTER-MAIN= ( ^
	 "%inputfile%" ^
	 -scale 346x490! ^
	 -gravity Northwest ^
	 -geometry +70+14 ^
	 "%foldervertical-main%" ) -compose over -composite ^
	 ( "%foldervertical-mainfx%" -scale 512x512! ) -compose over -composite

set LAYER-POSTER-SIDE= ( ^
	 "%inputfile%" ^
	 -scale 512x512! ^
	 -blur 0x19 ^
	 "%foldervertical-side%" ) -compose over -composite ^
	 ( "%foldervertical-sidefx%" -scale 512x512! ) -compose over -composite

set LAYER-POSTER-SIDE-SHADOW= ( "%foldervertical-sideshadow%" -scale 512x512! ) -compose over -composite
set LAYER-ICON-SIZE=-define icon:auto-resize="%TemplateIconSize%"
exit /b

:LAYER-RATING
if /i not "%display-movieinfo%" EQU "yes" exit /b
if not exist "*.nfo" (exit /b) else call "%RCFI%\resources\extract-NFO.bat"
if /i not "%Show-Rating%" EQU "yes" exit /b

set LAYER-STAR-IMAGE= ( ^
	 "%star-image%" ^
	 -scale 88x84! ^
	 -gravity Northwest ^
	 -geometry +46+417 ^
	 ( +clone -background BLACK -shadow 0x1.2+4+6 ) ^
	 +swap -background none -layers merge -extent 512x512 ^
	 ) -compose Over -composite
	 if not defined rating exit /b

set LAYER-RATING= ( ^
	 -font "%rcfi%\resources\ANGIE-BOLD.TTF" ^
	 -fill rgba(0,0,0,0.9) ^
	 -density 400 ^
	 -pointsize 6 ^
	 -kerning 0 ^
	 label:"%rating%" ^
	 -gravity Northwest ^
	 -geometry +58+440  ^
	 ( +clone -background ORANGE -shadow 30x1.2+2+2 ) +swap -background none -layers merge ^
	 ( +clone -background YELLOW -shadow 30x1.2-2-2 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 30x1.2-2+2 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 30x1.2+2-2 ) +swap -background none -layers merge ^
	 ) -compose Over -composite 
exit /b


:LAYER-GENRE
if /i not "%display-movieinfo%" EQU "yes" exit /b
if /i not "%Show-Genre%" EQU "yes" exit /b
if not defined GENRE exit /b

set LAYER-GENRE= ( ^
	 -font "%rcfi%\resources\ANGIE-BOLD.TTF" ^
	 -fill BLACK ^
	 -density 400 ^
	 -pointsize 5 ^
	 -kerning 0 ^
	 -gravity Northwest ^
	 -geometry +119+455 ^
	 label:"%genre%" ^
	 ( +clone -background ORANGE -shadow 70x1.2+2.5+2.5 ) +swap -background none -layers merge ^
	 ( +clone -background YELLOW -shadow 70x1.2-2.5-2.5 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 70x1.2-2.5+2.5 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 70x1.2+2.5-2.5 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK  -shadow 0x0.2+4+5 ) +swap -background none -layers merge ^
	 ) -composite 
exit /b

:LAYER-LOGO
if /i not "%use-Logo-instead-folderName%"=="yes" exit /b

if /i not "%custom-FolderName-HaveTheLogo%"=="yes"  if exist "*logo.png" (
	for %%D in (*logo.png) do set "Logo=%%~fD"&set "LogoName=%%~nxD"
) else exit /b

echo %TAB%%ESC%%g_%Logo        :%LogoName%%ESC%

set LAYER-LOGO-IMAGE= ( "%Logo%" ^
	 -trim +repage ^
	 -scale 160x50^ ^
	 -background none ^
	 -gravity center ^
	 -geometry +190-114 ^
	 -rotate 90 ^
	 ) -compose Over -composite
exit /b

:LAYER-CLEARART
if /i not "%display-clearArt%"=="yes" exit /b

if exist "*clearart.png" (
	for %%D in (*clearart.png) do set "ClearArt=%%~fD"&set "ClearArtName=%%~nxD"
) else exit /b

echo %TAB%%ESC%%g_%Clear Art   :%ClearArtName%%ESC%

set LAYER-CLEARART-IMAGE= ( "%clearart%" ^
	 -trim +repage ^
	 -scale 380x ^
	 -background none ^
	 -gravity SouthWest ^
	 -geometry -250-320 ^
	 ( +clone -background BLACK -shadow 40x40+10+10 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 40x40-10-10 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 40x40-10+10 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 40x40+10-10 ) +swap -background none -layers merge ^
	 ) -compose Over -composite
exit /b

:LAYER-FOLDER_NAME
if /i "%display-FolderName%"=="no" exit /b
if defined LAYER-LOGO-IMAGE exit /b

if /i not "%custom-FolderName%"=="yes" for %%F in ("%cd%") do set "foldername=%%~nxF"
if not defined foldername set "foldername=%cd:\=\\            %"&set "FolderNameLong-characters-limit=0"

set "FolNamShort=%foldername%"
set "FolNamShortLimit=%FolderNameShort-characters-limit%"
set /a "FolNamShortLimit=%FolNamShortLimit%+1"
set "FolNamLong=%foldername%"
set "FolNamLongLimit=%FolderNameLong-characters-limit%"
set /a "FolNamLongLimit=%FolNamLongLimit%+1"

:GetInfo-FolderName-Short
set /a FolNamShortCount+=1
if not "%_FolNamShort%"=="%FolderName%" (
	call set "_FolNamShort=%%FolderName:~0,%FolNamShortCount%%%"
	goto GetInfo-FolderName-Short
)
set /A "FolNamShortLimiter=%FolNamShortLimit%-4"
if %FolNamShortCount% GTR %FolNamShortLimit% call set "FolNamShort=%%FolderName:~0,%FolNamShortLimiter%%%..."

if %FolNamShortCount% LEQ %FolNamShortLimiter% (set "FolNamPos=-gravity Northwest -geometry +398+32") else (set "FolNamPos=-gravity center -geometry +200-114")
if /i "%FolderName-Center%"=="yes" set "FolNamPos=-gravity center -geometry +200-114"
if /i "%FolderName-Center%"=="no"  set "FolNamPos=-gravity Northwest -geometry +398+32"


:GetInfo-FolderName-Long
set /a FolNamLongCount+=1
if not "%_FolNamLong%"=="%FolderName%" (
	call set "_FolNamLong=%%FolderName:~0,%FolNamLongCount%%%"
	goto GetInfo-FolderName-Long
)
set /A "FolNamLongLimiter=%FolNamLongLimit%-4"
if %FolNamLongCount% GTR %FolNamLongLimit% call set "FolNamLong=%%FolderName:~0,%FolNamLongLimiter%%%..."

set LAYER-FOLDER-NAME-SHORT= ^
	 ( ^
	 -font Arial-Bold ^
	 -fill %FolderName-Font-Color% ^
	 -density 400 ^
	 -pointsize 5 ^
	 -kerning 0 ^
	 %FolNamPos% ^
	 -background none ^
	 label:"%FolNamShort%" ^
	 ( +clone -background BLACK -shadow 10x5+0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5-0.6-0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5-0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5+0.6-0.6 ) +swap -background none -layers merge ^
	 -rotate 90 ) -composite

if %FolNamShortCount% LEQ %FolNamShortLimit% exit /b
set LAYER-FOLDER-NAME-LONG= ^
	 ( ^
	 -font Arial-Bold  ^
	 -fill %FolderName-Font-Color% ^
	 -density 400 ^
	 -pointsize 3.1 ^
	 -kerning 2 ^
	 -gravity Northwest ^
	 -geometry +375+5 ^
	 -background none ^
	 label:"%FolNamLong%" ^
	 ( +clone -background BLACK -shadow 10x5+0.2+0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5-0.2-0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5-0.2+0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5+0.2-0.2 ) +swap -background none -layers merge ^
	 -rotate 90 ) -composite

if "%FolderNameLong-characters-limit%"=="0" set "LAYER-FOLDER-NAME-LONG="
exit /b

:::::::::::::::::::::::::::   CODE END   ::::::::::::::::::::::::::::::::::