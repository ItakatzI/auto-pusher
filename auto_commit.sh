#!/bin/bash

# === Load .env ===
ENV_PATH="$(dirname "$0")/.env"
if [ -f "$ENV_PATH" ]; then
  export $(grep -v '^#' "$ENV_PATH" | xargs)
else
  echo "[✘] .env file not found at $ENV_PATH"
  exit 1
fi

# === Sanity Check ===
if [ -z "$REPO_DIR" ] || [ -z "$TARGET_FILE" ]; then
  echo "[✘] Missing REPO_DIR or TARGET_FILE in .env"
  exit 1
fi

cd "$REPO_DIR" || { echo "[✘] Failed to cd into $REPO_DIR"; exit 1; }

MIN_COMMITS=0
MAX_COMMITS=5
NUM_COMMITS=$(( RANDOM % (MAX_COMMITS - MIN_COMMITS + 1) + MIN_COMMITS ))

echo "[✔] Starting $NUM_COMMITS motivational commits..."

for ((i=0; i<NUM_COMMITS; i++)); do
  # Fetch a quote
  RESPONSE=$(curl -s https://zenquotes.io/api/random)

  # Extract and clean
  RAW_QUOTE=$(echo "$RESPONSE" | grep -oP '"q":"\K[^"]+')
  RAW_AUTHOR=$(echo "$RESPONSE" | grep -oP '"a":"\K[^"]+')

  # Sanitize: convert to ASCII-safe
  CLEAN_QUOTE=$(echo "$RAW_QUOTE — $RAW_AUTHOR" | iconv -f utf-8 -t ascii//TRANSLIT | tr -cd '\11\12\15\40-\176')

  # Append as comment
  printf "# %s\n" "$CLEAN_QUOTE" >> "$TARGET_FILE"

  git add "$TARGET_FILE"
  git commit -m "Motivation: \"$CLEAN_QUOTE\" ($(date '+%Y-%m-%d %H:%M:%S'))"
  git push
done

echo "[✔] Done with $NUM_COMMITS motivational pushes."
