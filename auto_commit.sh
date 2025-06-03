#!/bin/bash

# === CONFIG ===
REPO_DIR="C:\Users\itai\Desktop\Journal"  # << CHANGE THIS
TARGET_FILE="README.md"     # << CHANGE THIS
MIN_COMMITS=1
MAX_COMMITS=5

cd "$REPO_DIR" || exit 1

NUM_COMMITS=$(( RANDOM % (MAX_COMMITS - MIN_COMMITS + 1) + MIN_COMMITS ))

for ((i=0; i<NUM_COMMITS; i++)); do
    # Sleep randomly between 5 and 30 minutes
    #SLEEP_TIME=$(( RANDOM % 1500 + 300 ))
    #sleep "$SLEEP_TIME"

    # Random whitespace change
    if (( RANDOM % 2 )); then
        echo " " >> "$TARGET_FILE"
    else
        sed -i '' -e '${s/ *$//}' "$TARGET_FILE"
    fi

    # Git commit and push
    git add "$TARGET_FILE"
    git commit -m "Auto whitespace tweak $(date '+%Y-%m-%d %H:%M:%S')"
    git push
done
