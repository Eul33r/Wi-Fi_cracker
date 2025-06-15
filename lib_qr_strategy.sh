#!/bin/bash

# wifi_recovery_tool/main.sh
# Skrypt do odzyskiwania zapisanych hasł Wi-Fi z Androida
echo "Program napisali Karol Kubek & chatGPT (c) 2025"
start=$(date +%s)

# ========== FUNKCJE ========== #
type_writer() {
    text="$1"
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep 0.02
    done
    echo ""
}

progress_bar() {
    for i in $(seq 1 50); do
        echo -ne "\r["
        for j in $(seq 1 $i); do echo -n "#"; done
        for j in $(seq $i 50); do echo -n "-"; done
        echo -n "] $((2*i))%"
        sleep 0.03
    done
    echo ""
}

# ========== START ========== #
type_writer "\n🧠 Sprawdzam wersję Androida..."
ANDROID_VERSION=$(adb shell getprop ro.build.version.release | tr -d '\r')
echo -e "\r✅ Wersja Androida: $ANDROID_VERSION"

sleep 0.5
type_writer "🔍 Analizuję strategię odzyskiwania hasł..."
sleep 0.5

if [[ ${ANDROID_VERSION:0:2} -ge 10 ]]; then
    type_writer "📲 Android >= 10 – uruchamiam metodę z kodami QR..."
    mkdir -p wifi_qrs

    SCREENSHOT="/sdcard/Download/wifi_qr.png"
    TIMESTAMP=$(date +%s)
    LOCAL_COPY="wifi_qrs/wifi_qr_${TIMESTAMP}.png"

    echo "📸 Robię zrzut ekranu (upewnij się, że kod QR jest widoczny)..."
    adb shell screencap -p "$SCREENSHOT"
    sleep 1

    echo "📥 Pobieram zrzut do komputera..."
    adb pull "$SCREENSHOT" "$LOCAL_COPY" > /dev/null

    if [[ ! -f "$LOCAL_COPY" ]]; then
        echo "❌ Nie udało się pobrać zrzutu z telefonu!"
        exit 1
    fi

    echo "📂 Zrzut zapisany jako: $LOCAL_COPY"
    # adb shell rm "$SCREENSHOT"  # KOMENTARZ: nie usuwamy zrzutu dla debugowania

    echo "🔍 Odczytuję hasło z QR (Python + pyzbar)..."

    if command -v python3 &> /dev/null; then
        python3 qr_decoder.py "$LOCAL_COPY"
    else
        echo "❌ Python 3 nie jest zainstalowany. Nie mogę odczytać kodu QR."
    fi

else
    type_writer "🔐 Android < 10 – sprawdzam root..."
    adb shell which su &> /dev/null
    if [ $? -eq 0 ]; then
        type_writer "✅ Root dostępny – odczytuję zapisane sieci..."
        bash lib/wifi_reader_root.sh
    else
        type_writer "❌ Brak dostępu root – odzyskanie niemożliwe dla tej wersji"
    fi
fi

end=$(date +%s)
runtime=$((end-start))
echo -e "\n⏱  Czas wykonania: ${runtime}s"
exit 0
