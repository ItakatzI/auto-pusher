#!/bin/bash

# === Config ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_PATH="$SCRIPT_DIR/.env"
LOG_PATH="$SCRIPT_DIR/push_log.txt"

# Log to both file and terminal
exec > >(tee -a "$LOG_PATH") 2>&1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting auto_commit.sh"

# === Load .env ===
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
Y
MAX_COMMITS=2
NUM_COMMITS=$(( RANDOM % (MAX_COMMITS - MIN_COMMITS + 1) + MIN_COMMITS ))

echo "[✔] Planning $NUM_COMMITS motivational commits..."

for ((i=0; i<NUM_COMMITS; i++)); do
  echo "[→] Commit $((i+1)) of $NUM_COMMITS"

  # Fetch a quote
  RESPONSE=$(curl -s https://zenquotes.io/api/random)

  if [ -z "$RESPONSE" ]; then
    echo "[!] Failed to fetch quote, skipping..."
    continue
  fi

  # Extract and sanitize quote
  RAW_QUOTE=$(echo "$RESPONSE" | sed -n 's/.*"q":"\([^"]*\)".*/\1/p')
  RAW_AUTHOR=$(echo "$RESPONSE" | sed -n 's/.*"a":"\([^"]*\)".*/\1/p')

  if [ -z "$RAW_QUOTE" ] || [ -z "$RAW_AUTHOR" ]; then
    echo "[!] Invalid quote structure, skipping..."
    continue
  fi

  CLEAN_QUOTE=$(echo "$RAW_QUOTE — $RAW_AUTHOR" | iconv -f utf-8 -t ascii//TRANSLIT | tr -cd '\11\12\15\40-\176')

  # Append and commit
  printf "# %s\n" "$CLEAN_QUOTE" >> "$TARGET_FILE"
  git add "$TARGET_FILE"
  git commit -m "Motivation: \"$CLEAN_QUOTE\" ($(date '+%Y-%m-%d %H:%M:%S'))"
  git push
  echo "[💬] $CLEAN_QUOTE"

  # Escape for PowerShell
  ESCAPED_QUOTE=$(echo "$CLEAN_QUOTE" | sed "s/'/''/g")

  # Windows notification (requires BurntToast module)
  powershell.exe -Command "New-BurntToastNotification -Text 'Motivational Commit', '$ESCAPED_QUOTE'"
done

echo "[✔] Completed $NUM_COMMITS commits."
