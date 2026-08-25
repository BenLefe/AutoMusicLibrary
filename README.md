# AutoMusicLibrary

## Prerequisites
- Python and libraries (Pandas, Music_Tag)
- Yt_dlp from https://github.com/yt-dlp/yt-dlp
- Shell : Bash
- Go in ~/.bashrc config and paste the alias contained in my bashrc file, it is a yt-dlp command that extracts cleanly from YouTube with metadata in mind

## Tutorial
- Download the content of this repo
- If you want to convert playlists and/or favorited music from the previous music service you used get a .CSV file using https://www.tunemymusic.com/
- Once you get the .CSV file, we should clean it then export it to .txt, use track_csv_to_txt_converter.py to do that
- You should now have a .txt file with lines formated as ytsearch:"Never Gonna Give You Up - Rick Astley"
- Use the process_playlist.sh script to automatically download the content of you playlist, this sould take a moment as the script waits for 8 seconds between requests in order to avoid bot flag by YouTube
- Once everything is downloaded, use the meta_fixer.py script to clean titles from YouTube garbage ("Official Video", "Lyrics", etc.)
