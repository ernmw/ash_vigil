#!/bin/bash
# Git passes: %O (Ancestor), %A (Current/Local), %B (Incoming/Remote)
ANCESTOR_FILE="$1"
CURRENT_FILE="$2"
INCOMING_FILE="$3"

# Create unique temporary paths for the JSON files
ANCESTOR_JSON=$(mktemp --suffix=.json)
CURRENT_JSON=$(mktemp --suffix=.json)
INCOMING_JSON=$(mktemp --suffix=.json)

# 1. Convert all three binary omwaddon states into JSON formats
tes3conv "$ANCESTOR_FILE" "$ANCESTOR_JSON"
tes3conv "$CURRENT_FILE" "$CURRENT_JSON"
tes3conv "$INCOMING_FILE" "$INCOMING_JSON"

# 2. Use Git's internal engine to merge the JSON data.
# This writes the merged JSON output directly into $CURRENT_JSON.
git merge-file --quiet "$CURRENT_JSON" "$ANCESTOR_JSON" "$INCOMING_JSON"
MERGE_STATUS=$?

# 3. Convert the finalized JSON merge result back to the target .omwaddon format
# (Git expects the resolved output to replace the %A file path)
tes3conv "$CURRENT_JSON" "$CURRENT_FILE"

# Clean up temporary storage files
rm -f "$ANCESTOR_JSON" "$CURRENT_JSON" "$INCOMING_JSON"

# Pass Git the true status code of the underlying JSON merge
exit $MERGE_STATUS
