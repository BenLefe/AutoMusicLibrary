#!/bin/bash

# Configuration (Keep the trailing slash on LOCAL_DIR)
LOCAL_DIR="/LOCAL/MUSIC/DIRECTORY"
PHONE_DIR="/DEVICE/MUSIC/DIRECTORY"
TARGET_DEVICE="DEVICE_SERIAL_NUMBER"  # Replace with your device's serial number from 'adb devices'

echo "============================================="
echo "             Music Sync Utility"
echo "============================================="

# 1. Environment Verification
if ! command -v adb &> /dev/null; then
    echo "[-] Error: 'adb' tool is not installed."
    echo "    Run: sudo pacman -S android-tools"
    exit 1
fi

# 2. Check Device Registration State
DEVICE_STATUS=$(adb devices | grep -w "$TARGET_DEVICE" | awk '{print $2}')

if [ -z "$DEVICE_STATUS" ]; then
    echo "[-] Error: Phone is not physically connected."
    exit 1
elif [ "$DEVICE_STATUS" = "unauthorized" ]; then
    echo "[!] Warning: Device unauthorized. Accept the prompt on your phone screen."
    exit 1
fi

echo "[+] Device authenticated. Scanning files..."

# 3. Purge Orphaned Files (Files on phone that were deleted locally)
# Reads the remote directory contents recursively using Android shell utilities
adb shell "find '$PHONE_DIR' -type f" | while read -r remote_file; do
    # Strip carriage returns added by Android ADB shell outputs
    remote_file=$(echo "$remote_file" | tr -d '\r')
    
    # Translate the phone's absolute path to what the local path should look like
    relative_path="${remote_file#$PHONE_DIR/}"
    local_file="$LOCAL_DIR$relative_path"
    
    # If the file does not exist on your computer, delete it from the phone
    if [ ! -f "$local_file" ] && [ -n "$relative_path" ]; then
        echo "[~] Removing deleted track from phone: $relative_path"
        adb shell rm -f "$remote_file"
    fi
done

# 4. Push New and Modified Tracks
echo "[+] Syncing new and modified tracks over USB..."
adb push "${LOCAL_DIR}." "$PHONE_DIR"

if [ $? -eq 0 ]; then
    echo "============================================="
    echo "[+] SUCCESS: Music library is now perfectly mirrored!"
    echo "============================================="
else
    echo "[-] Error: File stream transmission failed."
fi
