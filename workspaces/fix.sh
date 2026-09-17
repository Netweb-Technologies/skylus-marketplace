#!/usr/bin/env bash

set -euo pipefail

echo "================================================"
echo " Skylus Marketplace - Update existing 1.19.x"
echo " from current 1.18.x definitions"
echo "================================================"
echo

updated=0
skipped=0
failed=0

while IFS= read -r -d '' file; do
    workspace_dir=$(dirname "$file")
    workspace_name=$(basename "$workspace_dir")

    echo "Processing: $workspace_name"

    # Validate JSON
    if ! jq empty "$file" >/dev/null 2>&1; then
        echo "  [ERROR] Invalid JSON"
        ((failed+=1))
        continue
    fi

    # Must have 1.18.x source
    if ! jq -e '
        .compatibility[]? |
        select(.version == "1.18.x")
    ' "$file" >/dev/null; then
        echo "  [SKIP] No 1.18.x source entry"
        ((skipped+=1))
        continue
    fi

    # Must already have 1.19.x
    if ! jq -e '
        .compatibility[]? |
        select(.version == "1.19.x")
    ' "$file" >/dev/null; then
        echo "  [SKIP] No existing 1.19.x entry"
        ((skipped+=1))
        continue
    fi

    tmp=$(mktemp)

    jq '
        # Get the current 1.18.x entry
        ([.compatibility[] | select(.version == "1.18.x")][0]) as $source

        # Replace every existing 1.19.x entry with a copy of 1.18.x,
        # but expose it to the UI as 1.19.x
        |
        .compatibility |= map(
            if .version == "1.19.x"
            then ($source | .version = "1.19.x")
            else .
            end
        )
    ' "$file" > "$tmp"

    if jq empty "$tmp" >/dev/null 2>&1; then
        mv "$tmp" "$file"
        echo "  [UPDATED] Refreshed 1.19.x from 1.18.x"
        ((updated+=1))
    else
        echo "  [ERROR] Generated JSON invalid"
        rm -f "$tmp"
        ((failed+=1))
    fi

done < <(find . -type f -name 'workspace.json' -print0)

echo
echo "================================================"
echo "Completed"
echo "================================================"
echo "Updated : $updated"
echo "Skipped : $skipped"
echo "Failed  : $failed"