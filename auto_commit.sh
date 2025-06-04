#!/bin/bash

# === Load .env ===
ENV_PATH="$(dirname "$0")/.env"
if [ -f "$ENV_PATH" ]; then
  export $(grep -v '^#' "$ENV_PATH" | xargs)
else
  echo "[X] .env file not found at $ENV_PATH"
  exit 1
fi

# === CONFIG from .env ===
cd "$REPO_DIR" || { echo "[✘] Failed to cd into $REPO_DIR"; exit 1; }

MIN_COMMITS=1
MAX_COMMITS=5
NUM_COMMITS=$(( RANDOM % (MAX_COMMITS - MIN_COMMITS + 1) + MIN_COMMITS ))

echo "[✔] Starting $NUM_COMMITS whitespace commits on $(date)"

for ((i=0; i<NUM_COMMITS; i++)); do
    # Optional: sleep randomly between 5 and 30 minutes
    # SLEEP_TIME=$(( RANDOM % 1500 + 300 ))
    # sleep "$SLEEP_TIME"

    # Random whitespace change
    if (( RANDOM % 2 )); then
        echo " " >> "$TARGET_FILE"
    else
        sed -i'' -e '${s/[ \t]*$//}' "$TARGET_FILE"
    fi

    git add "$TARGET_FILE"
    git commit -m "Auto whitespace tweak $(date '+%Y-%m-%d %H:%M:%S')"
    git push
done

echo "[✔] Done with $NUM_COMMITS pushes."