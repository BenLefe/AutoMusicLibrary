import pandas as pd

# Load your exported Apple Music CSV
# Change 'playlist.csv' to your actual file name
df = pd.read_csv('library.csv')

# Clean column names (strips accidental spaces)
df.columns = df.columns.str.strip()

# Deduplicate based on Track Title and Artist
# Replace 'Title' and 'Artist' with your exact CSV column headers if they differ
df_clean = df.drop_duplicates(subset=['Track name', 'Artist name'])

# Format into yt-dlp search queries
with open('tracks.txt', 'w', encoding='utf-8') as f:
    for _, row in df_clean.iterrows():
        query = f'ytsearch:"{row["Track name"]} - {row["Artist name"]}"\n'
        f.write(query)

print("Cleaned tracks.txt created successfully!")
