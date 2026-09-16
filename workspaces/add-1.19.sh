#!/usr/bin/env bash

set -euo pipefail

NEW_VERSION="1.19.x"
NEW_TAG="1.19.0"

echo "================================================"
echo " Skylus Marketplace - Add ${NEW_VERSION}"
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

    # Check whether 1.19.x already exists
    if jq -e --arg version "$NEW_VERSION" \
        '.compatibility[]? | select(.version == $version)' \
        "$file" >/dev/null; then

        echo "  [SKIP] ${NEW_VERSION} already exists"
        ((skipped+=1))
        continue
    fi

    # Make sure a 1.18.x entry exists
    if ! jq -e \
        '.compatibility[]? | select(.version == "1.18.x")' \
        "$file" >/dev/null; then

        echo "  [SKIP] No 1.18.x compatibility entry"
        ((skipped+=1))
        continue
    fi

    tmp=$(mktemp)

    jq \
        --arg new_version "$NEW_VERSION" \
        --arg new_tag "$NEW_TAG" \
        '
        .compatibility += [
            (
                [.compatibility[] | select(.version == "1.18.x")][0]

                | .version = $new_version

                # Replace the Docker image tag while preserving repository
                | .image = (
                    .image
                    | sub(":[^:]+$"; ":" + $new_tag)
                )

                # Create the new available tags
                | .available_tags = [
                    "develop",
                    $new_tag,
                    ($new_tag + "-rolling-weekly"),
                    ($new_tag + "-rolling-daily")
                ]
            )
        ]
        ' "$file" > "$tmp"

    # Verify generated JSON before replacing original
    if jq empty "$tmp" >/dev/null 2>&1; then
        mv "$tmp" "$file"
        echo "  [UPDATED] Added ${NEW_VERSION}"
        ((updated+=1))
    else
        echo "  [ERROR] Generated JSON invalid"
        rm -f "$tmp"
        ((failed+=1))
    fi

done < <(find . -type f -name 'workspace.json' -print0)

echo
echo "================================================"
echo " Completed"
echo "================================================"
echo "Updated : $updated"
echo "Skipped : $skipped"
echo "Failed  : $failed"
echo "================================================"