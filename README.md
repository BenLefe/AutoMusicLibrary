# Apple Music / CSV to Local Library Pipeline

⚠️ **DISCLAIMER / WORK IN PROGRESS**
I am not a professional developer and I can make mistakes. This repository is a Work In Progress (WIP) and will be continuously updated and improved over time. 

**CRITICAL WARNINGS BEFORE USING:**
* **Column Names:** The parsing scripts rely heavily on the exact layout of your exported CSV. If your CSV columns differ (e.g., if Title isn't Column 1 or Artist isn't Column 2), the scripts may parse your files incorrectly or fail. Double-check your column structures before running!
* **Filenames & Folders:** Be **extremely careful** with the file names and file paths used inside these scripts. If your destination path paths are wrong or if files are named inconsistently, you risk mislabeling files or failing to skip tracks correctly. Always back up your music folder before testing scripts! Use at your own risk.

---

A semi-automated pipeline built for Arch Linux to convert streaming playlists into a cleanly organized local offline music library using `yt-dlp` and `music-tag`.

## Prerequisites

* **Bash Shell** (Linux/Unix natively supported)
* **Python 3.10+** with the following library:
  ```bash
  pip install music-tag
  ```
* **yt-dlp** installed natively on your system ([yt-dlp GitHub](https://github.com/yt-dlp/yt-dlp))
* **Firefox Browser** configuration tweak (allows `yt-dlp` to read active cookies while you continue browsing):
  1. Open Firefox and navigate to `about:config`.
  2. Search for `storage.sqlite.exclusiveLock.enabled`.
  3. Toggle it to `false`.

### Required `.bashrc` / `.zshrc` Alias
Add your custom `dlmusic` configuration to your shell startup configuration to handle proper media parsing and layout generation:
```bash
alias dlmusic='cd /path/to/your/Music && yt-dlp --cookies-from-browser firefox --download-archive downloaded_songs.txt -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --embed-metadata --parse-metadata "playlist_index:%(track_number)s" --parse-metadata "playlist_count:%(track_total)s" --parse-metadata "artist:%(album_artist)s" --parse-metadata "artist:%(performer)s" --replace-in-metadata "comment" ".*" "" --replace-in-metadata "description" ".*" "" -o "%(artist)s/%(album)s/%(playlist_index)s - %(title)s.%(ext)s"'
```

## Tutorial

### Step 1: Export Your Playlist
Export your playlists or favorite music from Apple Music into a raw `.csv` data file using [Tune My Music](https://www.tunemymusic.com/) or [Soundiiz](https://soundiiz.com). Name the resulting file `playlist.csv` and drop it into this directory.

### Step 2: Convert CSV to Search Queries
Run the native Bash converter script. This automatically removes absolute duplicates from the CSV, strips loose quotes, and structures names cleanly into a text query list:
```bash
chmod +x convert_playlist.sh
./convert_playlist.sh
```
This generates a local `tracks.txt` file.

### Step 3: Run the Safe Download Loop
Execute the automated downloader loop. The script automatically scans your existing local music folders to build an instant blocklist—skipping songs you already have in milliseconds while executing new downloads with an 8-second human delay to bypass YouTube bot walls:
```bash
chmod +x process_playlist.sh
./process_playlist.sh
```

### Step 4: Cleanup Metadata & YouTube Garbage
Once your downloads finish, run the Python automation script to scan your local folder hierarchy, hard-code correct ID3 tags, and cleanly remove toxic YouTube video junk (like `(Official Music Video)`, `(Lyrics)`, etc.) from song titles:
```bash
python meta_fixer.py
```

### Step 5: Final File Alignment
Open the directory inside **foobar2000**, select the tracks, right-click $\rightarrow$ **File Operations** $\rightarrow$ **Rename to...**, and apply the file naming pattern `%artist%/%album%/$num(%tracknumber%,2) - %title%` to perfectly synchronize your physical file manager layout with your clean embedded tags.
