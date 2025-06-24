#!/bin/bash

# === Config ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_PATH="$SCRIPT_DIR/.env"
LOG_PATH="$SCRIPT_DIR/push_log.txt"
# state file to remember which repo was used last time
LAST_REPO_FILE="$SCRIPT_DIR/.last_repo"

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
if [ -z "$REPO_DIR" ] || [ -z "$REPO_ALT" ] || [ -z "$TARGET_FILE" ]; then
  echo "[✘] Missing REPO_DIR, REPO_ALT or TARGET_FILE in .env"
  exit 1
fi

# === Choose which repo to use this run ===
if [ -f "$LAST_REPO_FILE" ]; then
  LAST=$(cat "$LAST_REPO_FILE")
else
  # default so that first run uses REPO_DIR
  LAST="ALT"
fi

if [ "$LAST" = "ALT" ]; then
  REPO="$REPO_DIR"
  echo "DIR" > "$LAST_REPO_FILE"
else
  REPO="$REPO_ALT"
  echo "ALT" > "$LAST_REPO_FILE"
fi

echo "[✔] Using repo: $REPO"

cd "$REPO" || { echo "[✘] Failed to cd into $REPO"; exit 1; }
git pull
# === Commit settings ===
MIN_COMMITS=${MIN_COMMITS:-1}
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
  git checkout -b "NewDailyQuote"
  printf "# %s\n" "$CLEAN_QUOTE" >> "$TARGET_FILE"
  git add "$TARGET_FILE"
  git commit -m "Motivation: \"$CLEAN_QUOTE\" ($(date '+%Y-%m-%d %H:%M:%S'))"
  git checkout main
  git merge NewDailyQuote
  git branch -d NewDailyQuote
  git push

  echo "[💬] $CLEAN_QUOTE"

  # Windows notification (requires BurntToast module)
  ESCAPED_QUOTE=$(echo "$CLEAN_QUOTE" | sed "s/'/''/g")
  powershell.exe -Command "New-BurntToastNotification -Text 'Motivational Commit', '$ESCAPED_QUOTE'"
done

echo "[✔] Completed $NUM_COMMITS commits."
