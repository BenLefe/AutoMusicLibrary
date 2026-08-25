#!/bin/bash

# 1. Initialize the local in-memory skip-list
declare -A already_downloaded

echo "Scanning local files to build safety blocklist..."

# 2. Automatically scan your destination folder to map files you already have
while IFS= read -r filepath; do
    filename=$(basename "$filepath")
    
    # Strip out track numbers, extensions, and lowercase the string
    clean_name=$(echo "$filename" | sed -E 's/^[0-9]+ - //; s/\.mp3$//' | tr '[:upper:]' '[:lower:]' | xargs)
    if [[ -n "$clean_name" ]]; then
        already_downloaded["$clean_name"]=1
    fi
done < <(find . -type f -name "*.mp3" 2>/dev/null)

echo "Ready! Cross-referencing tracks.txt against local storage..."
echo "-------------------------------------------------------"

# 3. Read your tracks.txt file line by line
while IFS= read -r track; do
    # Remove redundant prefixes and clean formatting
    clean_track=$(echo "$track" | sed 's/ytsearch://g' | tr -d '"' | xargs)
    [[ -z "$clean_track" ]] && continue
    
    lowercase_track=$(echo "$clean_track" | tr '[:upper:]' '[:lower:]')
    
    # Cross-reference with our mapped files
    matched=0
    for existing_song in "${!already_downloaded[@]}"; do
        if [[ "$lowercase_track" == *"$existing_song"* ]]; then
            matched=1
            break
        fi
    done

    # Skip files that exist locally
    if [[ $matched -eq 1 ]]; then
        continue
    fi
    
    # Execute download utilizing your custom .bashrc alias configuration
    echo "Downloading new track: $clean_track"
    dlmusic "ytsearch:$clean_track"
    
    # Look human to YouTube to protect your session tokens
    echo "Sleeping 8 seconds to prevent rate limits..."
    sleep 8
    
done < tracks.txt

echo "-------------------------------------------------------"
echo "All done! Library synchronization complete."
