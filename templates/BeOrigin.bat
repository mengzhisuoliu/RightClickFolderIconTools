:: Template-Version = v1.4
:: 2024-06-22 Fixed: Star image rendering even without an ".nfo" file.
:: 2024-06-24 Added: Global Config to override template settings via RCFI.template.ini.
:: 2024-09-30 Relocated: "NFO-file extractor" script to /resources/extract-NFO.bat.
:: 2024-09-30 Added: Option to choose the preferred rating from the .nfo file.
:: 2024-12-23 Added: Option to customize the folder name.


::                Template Info
::========================================================
::`  PSD Template by Jonathan Brimer
::`  https://beoriginal.com/blog/free-folder-icon-photoshop-template
::`  Convert and Edit using ImageMagick.
::` ------------------------------------------------------


::                Template Config
::========================================================
set "use-GlobalConfig=yes"
set "custom-FolderName=no"

::--------- Label --------------------------
set "display-FolderName=yes"
set "FolderNameShort-characters-limit=11"
set "FolderNameShort-font=Arial-Bold"
set "FolderNameLong-characters-limit=38"
set "FolderNameLong-font=Arial"
set "FolderName-Center=Auto"
set "FolderName-Font-Color=rgba(255,255,255,0.9)"

::--------- Movie Info ---------------------
set "display-movieinfo=yes"
set "show-Rating=yes"
set "preferred-rating=imdb"
set "show-Genre=yes"
set "genre-characters-limit=31"

::--------- Additional Art -----------------
set "use-Logo-instead-FolderName=yes"
set "display-clearArt=yes"

::--------- Additional Config --------------
set "Picture-Opacity=100%"
set "Background-Brightness=-5"
set "Background-Exposure=80"
set "Background-Contrast=27"
set "Background-Saturation=150"
set "Background-Blur=200"
set "Background-AmbientColor=2"
::========================================================


::                Images Source
::========================================================
set "BeOriginal-Back=%rcfi%\images\BeOriginal-Back.png"
set "BeOriginal-BackFx=%rcfi%\images\BeOriginal-BackFx.png"
set "BeOriginal-Front=%rcfi%\images\BeOriginal-Front.png"
set "BeOriginal-FrontFx=%rcfi%\images\BeOriginal-FrontFx.png"
set "star-image=%rcfi%\images\star.png"
set "canvas=%rcfi%\images\- canvas.png"
::========================================================


setlocal
call :LAYER-BASE
call :LAYER-RATING
call :LAYER-GENRE
call :LAYER-LOGO
call :LAYER-CLEARART
call :LAYER-FOLDER_NAME
 "%Converter%"             ^
  %LAYER-BACKGROUND%        ^
  %LAYER-BACK%              ^
  %LAYER-FOLDER-NAME-SHORT% ^
  %LAYER-FOLDER-NAME-LONG%  ^
  %LAYER-LOGO-IMAGE%        ^
  %LAYER-CLEARART-IMAGE%    ^
  %LAYER-FRONT%             ^
  %LAYER-STAR-IMAGE%        ^
  %LAYER-RATING%            ^
  %LAYER-GENRE%             ^
  %LAYER-ICON-SIZE%         ^
 "%OutputFile%"
endlocal
exit /b



:::::::::::::::::::::::::::   CODE START   :::::::::::::::::::::::::::::::::

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

set LAYER-BACKGROUND= ( "%canvas%" ^
	-scale 512x512! ^
	-background none ^
	-extent 512x512 ^
 ) -compose Over

set /a "PicOp=255*%Picture-Opacity%/100"
set "Picture-Opacity=-alpha set -channel A -evaluate set %PicOp% +channel"

set LAYER-FRONT= ( ^
	 "%inputfile%" ^
	 -scale 480x318! ^
	 -gravity Northwest ^
	 -geometry +18+124 ^
	 %Picture-Opacity% "%BeOriginal-Front%" )   -compose over -composite ^
	 ( "%BeOriginal-FrontFx%" -scale 512x512! ) -compose over -composite
	 
if /i "%Background-AmbientColor%"=="0" set LAYER-BACK= ( "%inputfile%" -scale 512x512! ) -compose over -composite

if /i not "%Background-AmbientColor%"=="0" set LAYER-BACK= ( ^
	 "%inputfile%" ^
	 -modulate 100x%Background-Saturation% ^
	 -modulate %Background-Exposure%x100 ^
	 -brightness-contrast 0x5 ^
	 -modulate 100x130 ^
	 -resize %Background-AmbientColor%x%Background-AmbientColor%! ^
	 -resize 1000x1000! ^
	 -scale 512x512! ^
	 -gravity Center ^
	 -blur 0x%Background-Blur% ^
	 -brightness-contrast %Background-Brightness%x0 ^
	 -brightness-contrast 0x%Background-Contrast% ^
	 -blur 0x20 ^
	 "%BeOriginal-Back%" ) -compose over -composite ^
	 ( "%BeOriginal-BackFx%" -scale 512x512! ) -compose over -composite
	 
set LAYER-ICON-SIZE=-define icon:auto-resize="%TemplateIconSize%"
exit /b

:LAYER-RATING
if /i not "%display-movieinfo%" EQU "yes" exit /b
if not exist "*.nfo" (exit /b) else call "%RCFI%\resources\extract-NFO.bat"
if /i not "%Show-Rating%" EQU "yes" exit /b

set LAYER-STAR-IMAGE= ( ^
	 "%star-image%" ^
	 -scale 88x88! ^
	 -gravity Northwest ^
	 -geometry +0+356 ^
	 ( +clone -background BLACK% ^
	 -shadow 40x1.2+1.8+3 ) ^
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
	 -geometry +13+383 ^
	 ( +clone -background ORANGE -shadow 30x1.2+2+2 ) +swap -background none -layers merge ^
	 ( +clone -background YELLOW -shadow 30x1.2-2-2 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 30x1.2-2+2 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 30x1.2+2-2 ) +swap -background none -layers merge ^
	 ) -compose Over -composite  
exit /b

:LAYER-GENRE
if /i not "%display-movieinfo%" EQU "yes" exit /b
if /i not "%Show-Genre%" EQU "yes" exit /b
if not defined genre exit /b

set LAYER-GENRE= ( ^
	 -font "%rcfi%\resources\ANGIE-BOLD.TTF" ^
	 -fill BLACK ^
	 -density 400 ^
	 -pointsize 5 ^
	 -kerning 0 ^
	 -gravity Northwest ^
	 -geometry +79+400 ^
	 label:"%genre%" ^
	 ( +clone -background ORANGE -shadow 70x1.2+2.6+2.6 ) +swap -background none -layers merge ^
	 ( +clone -background YELLOW -shadow 70x1.2-2.6-2.6 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 70x1.2-2.6+2.6 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 70x1.2+2.6-2.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK  -shadow 0x0.2+4+5 ) +swap -background none -layers merge ^
	 ) -composite 
exit /b

:LAYER-LOGO
if /i not "%use-Logo-instead-folderName%"=="yes" exit /b

if /i not "%custom-FolderName-HaveTheLogo%"=="yes" if exist "*logo.png" (
	for %%D in (*logo.png) do set "Logo=%%~fD"&set "LogoName=%%~nxD"
) else exit /b

echo %TAB% %G_%Logo        :%ESC%%LogoName%%ESC%

set LAYER-LOGO-IMAGE= ( "%Logo%" ^
	 -trim +repage ^
	 -scale 145x45^ ^
	 -background none ^
	 -gravity center ^
	 -geometry -155-157 ^
	 ) -compose Over -composite
exit /b

:LAYER-CLEARART
if /i not "%display-clearArt%"=="yes" exit /b

if exist "*clearart.png" (
	for %%D in (*clearart.png) do set "ClearArt=%%~fD"&set "ClearArtName=%%~nxD"
) else exit /b

echo %TAB% %G_%Clear Art   :%ESC%%ClearArtName%%ESC%

set LAYER-CLEARART-IMAGE= ( "%clearart%" ^
	 -trim +repage ^
	 -scale 295x123^ ^
	 -background none ^
	 -gravity South ^
	 -geometry +90+383 ^
	 ) -compose Over -composite
exit /b


:LAYER-FOLDER_NAME
if /i not "%display-FolderName%"=="yes" exit /b
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


set "FolNamCenter=-gravity center -geometry -155-165"
set "FolNamLeft=-gravity Northwest -geometry -5+35"
if %FolNamShortCount% LEQ %FolNamShortLimiter% (set "FolNamPos=%FolNamLeft%") else (set "FolNamPos=%FolNamCenter%")
if /i "%FolderName-Center%"=="yes" set "FolNamPos=%FolNamCenter%"
if /i "%FolderName-Center%"=="no"  set "FolNamPos=%FolNamLeft%"

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
	 -font "%FolderNameShort-font%" ^
	 -fill %FolderName-Font-Color% ^
	 -density 400 ^
	 -pointsize 4.5 ^
	 %FolNamPos% ^
	 -background none ^
	 label:"%FolNamShort%" ^
	 ( +clone -background BLACK -shadow 10x5+0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5-0.6-0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5-0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5+0.6-0.6 ) +swap -background none -layers merge ^
	 ) -composite

if %FolNamShortCount% LEQ %FolNamShortLimit% exit /b

set LAYER-FOLDER-NAME-LONG= ^
	 ( ^
	 -font "%FolderNameLong-font%" ^
	 -fill %FolderName-Font-Color% ^
	 -density 400 ^
	 -pointsize 2.5 ^
	 -kerning 2 ^
	 -gravity Northwest ^
	 -geometry +1+68 ^
	 label:"%FolNamLong%" ^
	 ( +clone -background BLACK -shadow 10x5+0.2+0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5-0.2-0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5-0.2+0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 10x5+0.2-0.2 ) +swap -background none -layers merge ^
	 ) -composite

if "%FolderNameLong-characters-limit%"=="0" set "LAYER-FOLDER-NAME-LONG="
exit /b

:::::::::::::::::::::::::::   CODE END   ::::::::::::::::::::::::::::::::::