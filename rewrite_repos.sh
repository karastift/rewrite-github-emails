#!/bin/bash

MAILMAP_FILE="./mailmap.txt"

if [ ! -f "$MAILMAP_FILE" ]; then
    echo "Error: Mailmap file not found at $MAILMAP_FILE"
    exit 1
fi

# Handle input: file or direct arguments
if [[ -f "$1" ]]; then
    REPO_LIST=$(cat "$1")
else
    REPO_LIST="$@"
fi

if [[ -z "$REPO_LIST" ]]; then
    echo "Usage: $0 <repo-list-file.txt> OR $0 repo-url1 repo-url2 ..."
    exit 1
fi

for REPO_URL in $REPO_LIST; do
    REPO_NAME=$(basename "$REPO_URL" .git)

    echo "=================================================================="
    echo "Processing repository: $REPO_NAME ($REPO_URL)"
    echo "=================================================================="

    git clone "$REPO_URL"
    if [[ $? -ne 0 ]]; then
        echo "Failed to clone – skipping"
        continue
    fi

    cd "$REPO_NAME" || continue

    # Rewrite history
    git filter-repo --mailmap "$MAILMAP_FILE" --force
    if [[ $? -ne 0 ]]; then
        echo "git filter-repo failed – skipping"
        cd ..
        rm -rf "$REPO_NAME"
        continue
    fi

    # Readd remotes because filter-repo removes all remotes for safety.
    git remote add origin "$REPO_URL"
    if [[ $? -ne 0 ]]; then
        echo "Failed to re-add remote origin – aborting this repo"
        cd ..
        rm -rf "$REPO_NAME"
        continue
    fi

    # Detect default branch using the full URL
    if git ls-remote --exit-code --heads "$REPO_URL" main >/dev/null 2>&1; then
        DEFAULT_BRANCH="main"
    elif git ls-remote --exit-code --heads "$REPO_URL" master >/dev/null 2>&1; then
        DEFAULT_BRANCH="master"
    else
        DEFAULT_BRANCH=$(git ls-remote --heads "$REPO_URL" | head -n1 | awk '{print $2}' | sed 's@^refs/heads/@@')
        if [[ -z "$DEFAULT_BRANCH" ]]; then
            echo "No remote branches found – aborting this repo"
            cd ..
            rm -rf "$REPO_NAME"
            continue
        fi
        echo "Warning: Using first available branch: $DEFAULT_BRANCH"
    fi

    echo "Detected default branch: $DEFAULT_BRANCH"

    # Force push
    git push origin "$DEFAULT_BRANCH" --force

    if [[ $? -eq 0 ]]; then
        echo "Successfully force-pushed $REPO_NAME to $DEFAULT_BRANCH"
    else
        echo "Push failed for $REPO_NAME – check SSH keys, permissions, or network"
    fi

    cd ..
    rm -rf "$REPO_NAME"
    echo ""
done

echo "All repositories processed."

