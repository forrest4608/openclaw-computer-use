#!/bin/bash
# Computer Use - Mouse Click Tool
# Usage: ./click.sh <action> <x> <y> [end_x] [end_y]
# Actions: click, right-click, double-click, drag

ACTION="${1:-click}"
X="${2}"
Y="${3}"

if [ -z "$X" ] || [ -z "$Y" ]; then
    echo "Usage: $0 <action> <x> <y> [end_x] [end_y]" >&2
    echo "Actions: click, right-click, double-click, drag, move" >&2
    exit 1
fi

case "$ACTION" in
    click)
        cliclick "c:${X},${Y}"
        ;;
    right-click)
        cliclick "rc:${X},${Y}"
        ;;
    double-click)
        cliclick "dc:${X},${Y}"
        ;;
    triple-click)
        cliclick "tc:${X},${Y}"
        ;;
    move)
        cliclick "m:${X},${Y}"
        ;;
    drag)
        END_X="${4}"
        END_Y="${5}"
        if [ -z "$END_X" ] || [ -z "$END_Y" ]; then
            echo "Drag requires end coordinates: $0 drag <x> <y> <end_x> <end_y>" >&2
            exit 1
        fi
        cliclick "dd:${X},${Y}" "du:${END_X},${END_Y}"
        ;;
    *)
        echo "Unknown action: $ACTION" >&2
        exit 1
        ;;
esac

echo "✅ ${ACTION} at (${X}, ${Y})"
