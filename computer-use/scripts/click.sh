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

# Get current mouse position
CURRENT_POS=$(cliclick p)
CURRENT_X=$(echo "$CURRENT_POS" | cut -d, -f1)
CURRENT_Y=$(echo "$CURRENT_POS" | cut -d, -f2)

# Generate smooth path to target using our Python helper
# Note: gen_bezier.py returns a string like "m:100,100 w:2 m:105,105 ..."
if [ -n "$X" ] && [ -n "$Y" ]; then
    # Only move if not already there (approx)
    if [ "$CURRENT_X" != "$X" ] || [ "$CURRENT_Y" != "$Y" ]; then
        MOVE_CMD=$(python3 "$(dirname "$0")/gen_bezier.py" "$CURRENT_X" "$CURRENT_Y" "$X" "$Y")
        if [ -n "$MOVE_CMD" ]; then
            # Execute movement
            cliclick $MOVE_CMD
        fi
    fi
fi

# Add random pre-click delay (human reaction time: 50-200ms)
cliclick "w:$(jot -r 1 50 200)"

case "$ACTION" in
    click)
        cliclick "c:."  # Click at current position
        ;;
    right-click)
        cliclick "rc:."
        ;;
    double-click)
        cliclick "dc:."
        ;;
    triple-click)
        cliclick "tc:."
        ;;
    move)
        # Movement already done above
        ;;
    drag)
        END_X="${4}"
        END_Y="${5}"
        if [ -z "$END_X" ] || [ -z "$END_Y" ]; then
            echo "Drag requires end coordinates: $0 drag <x> <y> <end_x> <end_y>" >&2
            exit 1
        fi
        
        # 1. Press down at start
        cliclick "dd:."
        
        # 2. Smooth move to end
        # Get start position (which is now X,Y)
        MOVE_CMD=$(python3 "$(dirname "$0")/gen_bezier.py" "$X" "$Y" "$END_X" "$END_Y")
        if [ -n "$MOVE_CMD" ]; then
             cliclick $MOVE_CMD
        fi
        
        # 3. Release at end
        cliclick "du:."
        ;;
    *)
        echo "Unknown action: $ACTION" >&2
        exit 1
        ;;
esac

echo "✅ ${ACTION} at (${X}, ${Y}) (Human-like)"
