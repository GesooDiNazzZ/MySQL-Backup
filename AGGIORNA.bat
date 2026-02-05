@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
color 07

:: Mostra l'ultimo autore del commit
for /f "delims=" %%a in ('git log -1 --pretty^=format:"%%an - %%ar"') do set LAST_COMMIT=%%a

:MENU
cls
echo.
echo -------------------------------------------
echo     GESTIONE DEL PROGETTO GIT [Minecraft]
echo -------------------------------------------
echo Ultimo salvataggio: [96m%LAST_COMMIT%[0m
echo -------------------------------------------
echo.
echo [93m1. SCARICA GLI ULTIMI FILE[0m - ottieni modifiche più recenti da GitHub
echo [92m2. SALVA LE TUE MODIFICHE[0m - invia le modifiche a GitHub
echo 3. Esci
echo.

set /p scelta=Scegli un'opzione [1-3]: 

if "%scelta%"=="1" goto SCARICA
if "%scelta%"=="2" goto SALVA
if "%scelta%"=="3" exit
goto MENU

:SCARICA
echo.
set /p conferma=Sei sicuro di voler [93mSCARICARE[0m gli ultimi file? (s/n): 
if /i "%conferma%"=="s" (
    echo.
    echo Scaricamento in corso da GitHub...
    git pull
    echo.
    echo ✔️ File scaricati correttamente.
) else (
    echo Operazione annullata.
)
pause
goto MENU

:SALVA
echo.
set /p conferma=Sei sicuro di voler [92mSALVARE[0m le tue modifiche? (s/n): 
if /i "%conferma%"=="s" (
    set /p msg=Inserisci un messaggio per il commit: 
    if not defined msg (
        echo.
        echo ⚠️ Errore: il messaggio di commit non può essere vuoto.
    ) else (
        echo.
        echo Salvataggio in corso su GitHub...
        git add .
        git commit -m "!msg!"
        git push
        echo.
        echo ✔️ Modifiche salvate correttamente.
    )
) else (
    echo Operazione annullata.
)
pause
goto MENU
