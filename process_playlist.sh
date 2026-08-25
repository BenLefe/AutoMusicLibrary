while IFS= read -r track; do
    clean_track=$(echo "$track" | sed 's/ytsearch://g' | tr -d '"' | xargs)
    [[ -z "$clean_track" ]] && continue
    
    lowercase_track=$(echo "$clean_track" | tr '[:upper:]' '[:lower:]')
    
    matched=0
    for existing_song in "${!already_downloaded[@]}"; do
        if [[ "$lowercase_track" == *"$existing_song"* ]]; then
            matched=1
            break
        fi
    done

    if [[ $matched -eq 1 ]]; then
        continue
    fi
    
    dlmusic "ytsearch:$clean_track"
    sleep 8
    
done < tracks.txt
