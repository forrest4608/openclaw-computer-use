#!/bin/bash
# Computer Use - Screen Information Tool
# Gets display resolution, mouse position, and active window info

echo "=== Screen Info ==="

# Display resolution
RESOLUTION=$(system_profiler SPDisplaysDataType 2>/dev/null | grep "Resolution:" | head -1 | sed 's/^[[:space:]]*//')
echo "Display: ${RESOLUTION}"

# Current mouse position
MOUSE_POS=$(cliclick p 2>/dev/null)
echo "Mouse Position: ${MOUSE_POS}"

# Active application
ACTIVE_APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
echo "Active App: ${ACTIVE_APP}"

# Active window title
WINDOW_TITLE=$(osascript -e 'tell application "System Events"
    set frontApp to first application process whose frontmost is true
    try
        set winTitle to name of front window of frontApp
    on error
        set winTitle to "N/A"
    end try
    return winTitle
end tell' 2>/dev/null)
echo "Window Title: ${WINDOW_TITLE}"

# List running GUI apps
echo ""
echo "=== Running GUI Apps ==="
osascript -e 'tell application "System Events"
    set appList to name of every application process whose background only is false
    set output to ""
    repeat with appName in appList
        set output to output & appName & ", "
    end repeat
    return output
end tell' 2>/dev/null
