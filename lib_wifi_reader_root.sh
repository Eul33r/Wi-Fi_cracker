#!/bin/bash

# lib/wifi_reader_root.sh
# Działa dla Androida z rootem – pobiera i parsuje WifiConfigStore.xml

echo "📥 Pobieram plik WifiConfigStore.xml z urządzenia (wymaga root)..."
adb shell su -c 'cat /data/misc/wifi/WifiConfigStore.xml' > wifi_dump.xml

if [[ ! -f wifi_dump.xml ]]; then
    echo "❌ Nie udało się pobrać pliku z Androida."
    exit 1
fi

echo "🔍 Przetwarzam zapisane sieci..."

# Parsowanie SSID i haseł z XML – proste podejście
grep -E 'SSID|PreSharedKey' wifi_dump.xml | sed 's/^[ \t]*//g' | paste - - | while IFS=$'\t' read -r ssid_line psk_line; do
    ssid=$(echo "$ssid_line" | sed -n 's/.*SSID="\(.*\)".*/\1/p')
    pass=$(echo "$psk_line" | sed -n 's/.*PreSharedKey="\(.*\)".*/\1/p')

    if [[ -n "$ssid" && -n "$pass" ]]; then
        echo -e "📡 Sieć: $ssid\n🔑 Hasło: $pass\n---"
    fi
done
