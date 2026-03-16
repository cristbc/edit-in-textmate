#!/bin/bash
# Edit in TextMate - Shell script for Automator Quick Action
# Version: 1.1 (Security Hardened)
#
# Usage: Receives selected text via stdin, opens in mate, returns edited text
# Security: Restrictive permissions, guaranteed cleanup, input size limit

set -euo pipefail

# Set restrictive umask before creating any files
umask 077

# Create secure temp directory
TMPDIR="$(mktemp -d)"

# CRITICAL: Setup cleanup trap IMMEDIATELY after mktemp, before any early exits
trap 'rm -rf "$TMPDIR"' EXIT INT TERM

# Ensure directory has restrictive permissions (redundant safety check)
chmod 700 "$TMPDIR"

# Create temp file
TMPFILE="$TMPDIR/edit-$(uuidgen).txt"
touch "$TMPFILE"
chmod 600 "$TMPFILE"  # Owner read/write only

# Input size limit: 10MB
MAX_SIZE=$((10 * 1024 * 1024))

# Read up to MAX_SIZE+1 bytes from stdin
head -c $((MAX_SIZE + 1)) > "$TMPFILE"

# Check actual file size
ACTUAL_SIZE=$(stat -f%z "$TMPFILE" 2>/dev/null || stat -c%s "$TMPFILE")

if [ "$ACTUAL_SIZE" -gt "$MAX_SIZE" ]; then
    echo "ERROR: Input exceeds maximum size (10MB)" >&2
    exit 1
fi

# Open in TextMate (blocking)
if [[ -x /usr/local/bin/mate ]]; then
    /usr/local/bin/mate -w "$TMPFILE"
elif [[ -x /opt/homebrew/bin/mate ]]; then
    /opt/homebrew/bin/mate -w "$TMPFILE"
else
    echo "ERROR: TextMate CLI (mate) not found" >&2
    exit 1
fi

# Return edited content
cat "$TMPFILE"

# Cleanup handled automatically by EXIT trap
