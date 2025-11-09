#!/bin/bash

# Script de build IPA pour Monetia
# Crée un fichier IPA dans ~/Desktop/build/

set -e

echo "🚀 Début du build Monetia..."

# Configuration
PROJECT_PATH="./Monetia.xcodeproj"
SCHEME_NAME="Monetia"
ARCHIVE_PATH="$HOME/Desktop/build/Monetia.xcarchive"
EXPORT_PATH="$HOME/Desktop/build"
TEAM_ID="4DVLAK4L8N"

# Créer le dossier build s'il n'existe pas
echo "📁 Création du dossier build..."
mkdir -p "$HOME/Desktop/build"

# Nettoyer l'ancien build
echo "🧹 Nettoyage des anciens builds..."
rm -rf "$ARCHIVE_PATH"
rm -f "$EXPORT_PATH/Monetia.ipa"

# Créer le fichier ExportOptions.plist
echo "📝 Création de ExportOptions.plist..."
cat > "$HOME/Desktop/build/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
EOF

# Archiver l'application
echo "📦 Archivage de l'application..."
xcodebuild archive \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME_NAME" \
    -destination "generic/platform=iOS" \
    -archivePath "$ARCHIVE_PATH" \
    -configuration Release \
    CODE_SIGN_IDENTITY="Apple Development" \
    | grep -E '(▸|Building|Archiving|Signing|error|warning|succeeded|failed)' || true

# Vérifier que l'archive a réussi
if [ ! -d "$ARCHIVE_PATH" ]; then
    echo "❌ Erreur: L'archivage a échoué"
    exit 1
fi

echo "✅ Archive créée avec succès!"

# Exporter l'IPA
echo "📤 Export de l'IPA..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$HOME/Desktop/build/ExportOptions.plist" \
    | grep -E '(▸|Exporting|Signing|error|warning|succeeded|failed)' || true

# Vérifier que l'IPA a été créé
if [ -f "$EXPORT_PATH/Monetia.ipa" ]; then
    echo ""
    echo "✅ ✅ ✅ BUILD RÉUSSI! ✅ ✅ ✅"
    echo ""
    echo "📱 IPA créé à: $EXPORT_PATH/Monetia.ipa"
    echo "📊 Taille: $(du -h "$EXPORT_PATH/Monetia.ipa" | cut -f1)"
    echo ""
    ls -lh "$EXPORT_PATH/Monetia.ipa"
else
    echo "❌ Erreur: L'export de l'IPA a échoué"
    exit 1
fi
