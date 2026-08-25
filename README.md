# Edit in TextMate

> **Unmaintained.** I built this for my own machine and it does what I need. I'm not
> reviewing issues or pull requests — fork it and take it wherever you like. MIT licensed.

macOS Service for system-wide text editing. Select text in any app, invoke service, edit in TextMate, changes replace original selection.

**Version:** 1.1 (Security Hardened)
**Platform:** macOS 15.7.2+ (Sequoia)
**Status:** Production Ready

---

## Quick Start

```bash
# Deploy
./deploy.sh

# Enable (required)
System Settings → Keyboard → Keyboard Shortcuts → Services
→ Check "Edit in TextMate" under Text section

# Use
Select text → Right-click → Services → "Edit in TextMate"
# OR: ⌘⌥E
```

---

## Requirements

- macOS 15.7.2+
- TextMate 2.x with CLI installed (`mate` in PATH)

Verify TextMate CLI:
```bash
which mate  # Should show /usr/local/bin/mate or /opt/homebrew/bin/mate
```

If missing: TextMate → Preferences → Terminal → Install

---

## How It Works

1. User selects text in any Service-aware app
2. Invokes via menu or ⌘⌥E
3. Shell script creates secure temp file, launches `mate -w`
4. User edits in TextMate, saves and closes
5. Script returns edited text, macOS replaces selection
6. Temp file cleaned up automatically

**Supported Apps:** TextEdit, Mail, Safari, Notes, Messages, Pages, and any NSServices-compatible app.

**Not Supported:** Terminal, most Electron apps, web apps (Gmail, Google Docs).

---

## Security Features (v1.1)

| Feature | Implementation |
|---------|----------------|
| File Permissions | Owner-only (600 file, 700 dir) via `umask 077` |
| Cleanup Guarantee | EXIT/INT/TERM trap prevents leaks |
| Input Limit | 10MB max prevents disk exhaustion |
| Type Compatibility | Multiple pasteboard types for broad app support |

All vulnerabilities from v1.0 audit have been remediated.

---

## Project Structure

```
edit-in-textmate/
├── README.md                       # This file
├── deploy.sh                       # Deployment script
├── edit-in-textmate.sh             # Shell script (standalone reference)
└── Edit in TextMate.workflow/      # Automator Quick Action
    └── Contents/
        ├── Info.plist              # Service registration
        └── document.wflow          # Workflow with embedded script
```

**Production Location:** `~/Library/Services/Edit in TextMate.workflow/`

---

## Deployment

### Fresh Install
```bash
./deploy.sh
```

### Manual Install
```bash
cp -R "Edit in TextMate.workflow" ~/Library/Services/
chmod -R 755 ~/Library/Services/"Edit in TextMate.workflow"
/System/Library/CoreServices/pbs -flush
killall cfprefsd
```

### To Another Machine
Copy entire project directory, run `./deploy.sh`, enable in System Settings.

---

## Troubleshooting

### Service not appearing
```bash
/System/Library/CoreServices/pbs -flush
killall cfprefsd SystemUIServer
```

### Service grayed out
- Ensure text is selected
- Try in TextEdit to verify service works

### TextMate doesn't open
```bash
# Check CLI exists
which mate

# Install if missing
# TextMate → Preferences → Terminal → Install
```

### Edited text not replacing original
Ensure Automator action configured as "Pass input: to stdin" (not "as arguments").

### Permission errors
```bash
chmod -R 755 ~/Library/Services/"Edit in TextMate.workflow"
```

---

## Shell Script Reference

The core script (`edit-in-textmate.sh`):

```bash
#!/bin/bash
set -euo pipefail

umask 077
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT INT TERM
chmod 700 "$TMPDIR"

TMPFILE="$TMPDIR/edit-$(uuidgen).txt"
touch "$TMPFILE"
chmod 600 "$TMPFILE"

MAX_SIZE=$((10 * 1024 * 1024))
head -c $((MAX_SIZE + 1)) > "$TMPFILE"
ACTUAL_SIZE=$(stat -f%z "$TMPFILE" 2>/dev/null || stat -c%s "$TMPFILE")

if [ "$ACTUAL_SIZE" -gt "$MAX_SIZE" ]; then
    echo "ERROR: Input exceeds maximum size (10MB)" >&2
    exit 1
fi

if [[ -x /usr/local/bin/mate ]]; then
    /usr/local/bin/mate -w "$TMPFILE"
elif [[ -x /opt/homebrew/bin/mate ]]; then
    /opt/homebrew/bin/mate -w "$TMPFILE"
else
    echo "ERROR: TextMate CLI (mate) not found" >&2
    exit 1
fi

cat "$TMPFILE"
```

---

## Alternative Editors

Modify the script to use other editors with "wait" flags:

```bash
# BBEdit
/usr/local/bin/bbedit -w "$TMPFILE"

# VS Code
/usr/local/bin/code --wait "$TMPFILE"

# Sublime Text
/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl -w "$TMPFILE"
```

---

## Changelog

**v1.1** (2025-11-22) - Security Hardened
- Fixed: Temp file permission exposure (High)
- Fixed: Missing cleanup trap (High)
- Fixed: Unbounded input size (Medium)
- Added: Broader pasteboard type support
- Status: Production ready, DevOps approved

**v1.0** (2025-11-22) - Initial Release
- Deprecated due to security vulnerabilities

---

## License

Personal use. Modify as needed.
