import os
import re
import music_tag

MUSIC_DIR = "/mnt/c68ff51e-f39b-4a73-b0c7-ad8c9f8a593e/Music"

YOUTUBE_GARBAGE = [
    r'\(Official Music Video\)', r'\(Official Video\)', r'\(Music Video\)', 
    r'\(Official Audio\)', r'\[Official Video\]', r'\(Lyric Video\)', r'\(Lyrics\)'
]

def format_fallback_artist(folder_name):
    """Cleans up folder names like '3doorsdown' into '3 Doors Down' as a safety net."""
    if folder_name.lower() == "3doorsdown":
        return "3 Doors Down"
    # Capitalizes the first letter of words if no spaces exist (e.g., falloutboy -> Falloutboy)
    return folder_name.strip()

print(f"Scanning directory: {MUSIC_DIR}...")
fixed_count = 0

for root, dirs, files in os.walk(MUSIC_DIR):
    for file in files:
        if file.lower().endswith('.mp3'):
            file_path = os.path.join(root, file)
            
            # 1. Grab folder context relative to your base directory
            relative_path = os.path.relpath(file_path, MUSIC_DIR)
            path_parts = relative_path.split(os.sep)
            
            # Default fallbacks from directory structure
            folder_artist = format_fallback_artist(path_parts[0]) if len(path_parts) >= 1 else "Unknown Artist"
            folder_album = path_parts[1] if len(path_parts) >= 3 else "Unknown Album"
            
            filename = os.path.splitext(file)[0]
            
            # 2. Strip out raw YouTube clutter right away
            for pattern in YOUTUBE_GARBAGE:
                filename = re.sub(pattern, '', filename, flags=re.IGNORECASE).strip()
            
            # 3. Extract Track Number if it exists (e.g., "01 - ...")
            track_num = None
            num_match = re.match(r'^(\d+)\s*-\s*(.+)$', filename)
            if num_match:
                track_num = int(num_match.group(1))
                filename = num_match.group(2).strip() # keep everything after the track number
            
            # 4. Smart Metadata Assignment based on string patterns
            final_artist = folder_artist
            final_title = filename
            
            # If the filename contains a dash, split it to see what's inside
            if " - " in filename:
                parts = [p.strip() for p in filename.split(" - ", 1)]
                
                # Case A: Filename is "Artist - Title" (e.g., 3 Doors Down - Away From The Sun)
                if parts[0].lower().replace(" ", "") == folder_artist.lower().replace(" ", ""):
                    final_artist = parts[0]
                    final_title = parts[1]
                # Case B: Filename is "Title - Artist" 
                elif parts[1].lower().replace(" ", "") == folder_artist.lower().replace(" ", ""):
                    final_artist = parts[1]
                    final_title = parts[0]
                # Case C: The filename contains a dash but doesn't explicitly match the parent folder
                else:
                    final_artist = parts[0]
                    final_title = parts[1]
            
            # 5. Write tags back safely into the file
            try:
                f = music_tag.load_file(file_path)
                
                f['title'] = final_title
                f['artist'] = final_artist
                f['albumartist'] = final_artist
                
                # Only overwrite album and track if they are valid
                if folder_album != "Unknown Album":
                    f['album'] = folder_album
                if track_num is not None:
                    f['tracknumber'] = track_num
                    
                f.save()
                fixed_count += 1
                
            except Exception as e:
                print(f"Error skipping/writing file {file}: {e}")

print("-------------------------------------------------------")
print(f"Inconsistency-proof metadata cleanup complete! Tagged {fixed_count} files.")
print("-------------------------------------------------------")
