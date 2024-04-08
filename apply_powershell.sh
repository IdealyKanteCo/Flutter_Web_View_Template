# Fonction pour afficher les erreurs
function afficher_erreur {
    param(
        [string]$message
    )
    Write-Host "Erreur : $message" -ForegroundColor Red
}

# Fonction pour vérifier si un fichier existe
function verifier_fichier {
    param(
        [string]$chemin_fichier
    )
    if (-not (Test-Path $chemin_fichier)) {
        afficher_erreur "Le fichier $chemin_fichier n'existe pas"
        exit 1
    }
}

# Fonction pour installer Flutter localement
function installer_flutter {
    $flutter_url = "https://storage.googleapis.com/flutter_infra/releases/stable/windows/flutter_windows_$(if ([Environment]::Is64BitOperatingSystem) {'x64'} else {'x86'}).zip"
    $install_dir = "$env:USERPROFILE\flutter"
    Write-Host "Téléchargement et installation de Flutter..."
    mkdir $install_dir | Out-Null
    Invoke-WebRequest -Uri $flutter_url -OutFile "$install_dir\flutter.zip"
    Expand-Archive -Path "$install_dir\flutter.zip" -DestinationPath $install_dir
    $env:PATH += ";$install_dir\flutter\bin"
}

# Vérifier si Flutter est installé
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    installer_flutter
}

# Exécuter 'flutter pub get'
flutter pub get
if ($LASTEXITCODE -ne 0) {
    afficher_erreur "Erreur lors de l'exécution de 'flutter pub get'"
    exit 1
}

# Lire le fichier param.conf
$parametres = Get-Content "./param.conf"
if ($null -eq $parametres) {
    afficher_erreur "Erreur lors de la lecture de param.conf"
    exit 1
}

# Vérifier si le fichier logo_app existe
verifier_fichier $parametres[1]

# Vérifier chaque paramètre
foreach ($parametre in $parametres) {
    if ([string]::IsNullOrWhiteSpace($parametre)) {
        afficher_erreur "$parametre n'est pas défini"
        exit 1
    }
}

# Remplacer les valeurs dans le fichier .env
$env_file = Get-Content ".env"
$env_file -replace '^WEB_VIEW_LINK=.*', "WEB_VIEW_LINK='$parametres[2]'" | Set-Content ".env"
$env_file -replace '^APP_BG_COLOR=.*', "APP_BG_COLOR='$parametres[3]'" | Set-Content ".env"

# Traiter les paramètres spécifiques
if (![string]::IsNullOrWhiteSpace($parametres[0])) {
    dart run rename_app:main all="$parametres[0]" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        afficher_erreur "Erreur lors du renommage de l'application"
    }
}

if (![string]::IsNullOrWhiteSpace($parametres[1])) {
    $LOGO_APP_escaped = $parametres[1] -replace '([&/\])', '\\$1'
    (Get-Content "$(Get-Location)/launcher_icons.yaml") -replace 'image_path: .*', "image_path: ""$LOGO_APP_escaped""" | Set-Content "$(Get-Location)/launcher_icons.yaml"
    dart run flutter_launcher_icons -f "$(Get-Location)/launcher_icons.yaml" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        afficher_erreur "Erreur lors de l'exécution de flutter_launcher_icons"
    }
}

if (![string]::IsNullOrWhiteSpace($parametres[4])) {
    $LOGO_LANCEMENT_escaped = $parametres[4] -replace '([&/\])', '\\$1'
    (Get-Content "$(Get-Location)/flutter_native_splash.yaml") -replace 'image: .*', "image: ""$LOGO_LANCEMENT_escaped""" | Set-Content "$(Get-Location)/flutter_native_splash.yaml"
    dart run flutter_native_splash:create --path="$(Get-Location)/flutter_native_splash.yaml" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        afficher_erreur "Erreur lors de la création de l'écran de lancement"
    }
}

flutter build appbundle
flutter build apk --split-per-abi

Write-Host "Le script s'est exécuté avec succès."
