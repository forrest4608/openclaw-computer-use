#!/bin/bash
# Computer Use - Window Control Tool
# Usage: ./window-control.sh <action> <app_name> [params...]
# Actions: focus, list, resize, position, minimize, fullscreen

ACTION="${1}"
APP_NAME="${2}"

if [ -z "$ACTION" ] || [ -z "$APP_NAME" ]; then
    echo "Usage: $0 <action> <app_name> [params...]" >&2
    echo "Actions:" >&2
    echo "  focus <app>              - Bring app to front" >&2
    echo "  list <app>               - List all windows" >&2
    echo "  resize <app> <w> <h>     - Resize front window" >&2
    echo "  position <app> <x> <y>   - Move front window" >&2
    echo "  minimize <app>           - Minimize front window" >&2
    exit 1
fi

case "$ACTION" in
    focus)
        osascript -e "tell application \"${APP_NAME}\" to activate"
        sleep 0.5
        echo "✅ Focused: ${APP_NAME}"
        ;;
    list)
        osascript -e "
tell application \"System Events\"
    tell process \"${APP_NAME}\"
        set windowList to every window
        set output to \"\"
        repeat with w in windowList
            set winName to name of w
            set winPos to position of w
            set winSize to size of w
            set output to output & winName & \" | pos:\" & (item 1 of winPos) & \",\" & (item 2 of winPos) & \" | size:\" & (item 1 of winSize) & \"x\" & (item 2 of winSize) & return
        end repeat
        return output
    end tell
end tell"
        ;;
    resize)
        W="${3}"
        H="${4}"
        osascript -e "
tell application \"System Events\"
    tell process \"${APP_NAME}\"
        set size of front window to {${W}, ${H}}
    end tell
end tell"
        echo "✅ Resized ${APP_NAME} to ${W}x${H}"
        ;;
    position)
        X="${3}"
        Y="${4}"
        osascript -e "
tell application \"System Events\"
    tell process \"${APP_NAME}\"
        set position of front window to {${X}, ${Y}}
    end tell
end tell"
        echo "✅ Moved ${APP_NAME} to (${X}, ${Y})"
        ;;
    minimize)
        osascript -e "
tell application \"System Events\"
    tell process \"${APP_NAME}\"
        set miniaturized of front window to true
    end tell
end tell" 2>/dev/null || osascript -e "
tell application \"${APP_NAME}\"
    set miniaturized of front window to true
end tell"
        echo "✅ Minimized ${APP_NAME}"
        ;;
    *)
        echo "Unknown action: $ACTION" >&2
        exit 1
        ;;
esac
