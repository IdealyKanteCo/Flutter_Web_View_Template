@echo off
setlocal EnableDelayedExpansion

rem Fonction pour afficher les erreurs
:afficher_erreur
    echo Erreur : %1
    exit /b 1

rem Fonction pour vérifier si un fichier existe
:verifier_fichier
    if not exist "%~1" call :afficher_erreur "Le fichier %~1 n'existe pas"
    exit /b 0

rem Fonction pour installer Flutter localement
:installer_flutter
    set "flutter_url=https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_%PROCESSOR_ARCHITECTURE%.tar.xz"
    set "install_dir=%USERPROFILE%\flutter"
    echo Téléchargement et installation de Flutter...
    mkdir "%install_dir%" 2>nul
    bitsadmin.exe /transfer "FlutterDownload" "%flutter_url%" "%install_dir%\flutter.tar.xz"
    tar.exe -xJf "%install_dir%\flutter.tar.xz" -C "%install_dir%"
    set "PATH=%install_dir%\flutter\bin;%PATH%"
    exit /b 0

rem Vérifier si Flutter est installé
where flutter >nul 2>&1 || call :installer_flutter

rem Exécuter 'flutter pub get'
flutter pub get || call :afficher_erreur "Erreur lors de l'exécution de 'flutter pub get'"

rem Lire le fichier param.conf
call :verifier_fichier "param.conf"

rem Vérifier si le fichier logo_app existe
call :verifier_fichier "%LOGO_APP%"

rem Vérifier chaque paramètre
set "parametres=NOM_APP LOGO_APP LIEN_WEB_VIEW BG_APP LOGO_LANCEMENT"
for %%p in (%parametres%) do (
    if not defined %%p call :afficher_erreur "%%p n'est pas défini"
)

rem Fonction pour remplacer une valeur dans un fichier
:remplacer_valeur
    set "nom_variable=%~1"
    set "nouvelle_valeur=%~2"
    set "fichier=%~3"
    (for /f "tokens=1* delims==" %%A in ('type "%fichier%"') do (
        if "%%A"=="!nom_variable!" (
            echo !nom_variable!=!nouvelle_valeur!
        ) else (
            echo %%A=%%B
        )
    )) > "%fichier%.new"
    move /y "%fichier%.new" "%fichier%" >nul
    exit /b 0

rem Remplacer les valeurs dans le fichier .env
call :remplacer_valeur "WEB_VIEW_LINK" "%LIEN_WEB_VIEW%" ".env"
call :remplacer_valeur "APP_BG_COLOR" "%BG_APP%" ".env"

rem Traiter les paramètres spécifiques
if defined NOM_APP (
    dart run rename_app:main all="%NOM_APP%" || call :afficher_erreur "Erreur lors du renommage de l'application"
)

if defined LOGO_APP (
    set "LOGO_APP_escaped=!LOGO_APP:&=^&!"
    sed -i "s/image_path: .*/image_path: \"!LOGO_APP_escaped!\"/" "%CD%\launcher_icons.yaml" || call :afficher_erreur "Erreur lors du remplacement de image_path dans launcher_icons.yaml"
    dart run flutter_launcher_icons -f "%CD%\launcher_icons.yaml" || call :afficher_erreur "Erreur lors de l'exécution de flutter_launcher_icons"
)

if defined LOGO_LANCEMENT (
    set "LOGO_LANCEMENT_escaped=!LOGO_LANCEMENT:&=^&!"
    sed -i "s/image: .*/image: \"!LOGO_LANCEMENT_escaped!\"/" "%CD%\flutter_native_splash.yaml" || call :afficher_erreur "Erreur lors du remplacement de image dans flutter_native_splash.yaml"
    dart run flutter_native_splash:create --path="%CD%\flutter_native_splash.yaml" || call :afficher_erreur "Erreur lors de la création de l'écran de lancement"
)

flutter build appbundle
flutter build apk --split-per-abi

echo Le script s'est exécuté avec succès.
