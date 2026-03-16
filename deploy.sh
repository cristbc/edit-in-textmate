#!/bin/bash
# Deploy "Edit in TextMate" service
# Version: 1.1 (Security Hardened)

set -euo pipefail

echo "=== Edit in TextMate Service Deployment (v1.1) ==="
echo ""

# Check for TextMate CLI
if ! command -v mate &>/dev/null; then
    echo "WARNING: TextMate CLI (mate) not found in PATH"
    echo "  Install: TextMate → Preferences → Terminal → Install"
    echo ""
fi

# Check if workflow exists
if [[ ! -d "Edit in TextMate.workflow" ]]; then
    echo "ERROR: 'Edit in TextMate.workflow' not found in current directory"
    exit 1
fi

# Create Services directory if needed
mkdir -p ~/Library/Services

# Copy workflow
echo "Installing workflow..."
cp -R "Edit in TextMate.workflow" ~/Library/Services/
chmod -R 755 ~/Library/Services/"Edit in TextMate.workflow"
echo "  Installed to ~/Library/Services/"

# Flush services cache
echo "Registering service..."
/System/Library/CoreServices/pbs -flush
killall cfprefsd 2>/dev/null || true
echo "  Service registered"
echo ""

echo "=== Next Steps ==="
echo ""
echo "1. Enable the service:"
echo "   System Settings → Keyboard → Keyboard Shortcuts → Services"
echo "   Check 'Edit in TextMate' under Text section"
echo ""
echo "2. Test: Select text → Right-click → Services → 'Edit in TextMate'"
echo "   Or press ⌘⌥E"
echo ""
echo "Done!"
