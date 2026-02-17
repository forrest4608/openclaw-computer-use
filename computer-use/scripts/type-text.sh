#!/bin/bash
# Computer Use - Keyboard Input Tool
# Usage: ./type-text.sh <action> <content>
# Actions: type, key, shortcut

ACTION="${1:-type}"
CONTENT="${2}"

if [ -z "$CONTENT" ]; then
    echo "Usage: $0 <action> <content>" >&2
    echo "Actions:" >&2
    echo "  type <text>        - Type text string" >&2
    echo "  key <keyname>      - Press a key (return, tab, esc, space, delete, etc.)" >&2
    echo "  shortcut <keys>    - Press shortcut (e.g., cmd+c, cmd+v, cmd+shift+s)" >&2
    exit 1
fi

case "$ACTION" in
    type)
        # Check for non-ASCII characters by removing all ASCII characters
        # If the resulting string is not empty, it contains non-ASCII characters
        if [[ -n "${CONTENT//[[:ascii:]]/}" ]]; then
            echo -n "$CONTENT" | pbcopy
            cliclick "kd:cmd" "w:100" "t:v" "ku:cmd"
            echo "✅ Pasted (Non-ASCII): ${CONTENT}"
        else
            cliclick "t:${CONTENT}"
            echo "✅ Typed: ${CONTENT}"
        fi
        ;;
    paste)
        echo -n "$CONTENT" | pbcopy
        cliclick "kd:cmd" "w:100" "t:v" "ku:cmd"
        echo "✅ Pasted: ${CONTENT}"
        ;;
    key)
        cliclick "kp:${CONTENT}"
        echo "✅ Pressed key: ${CONTENT}"
        ;;
    shortcut)
        # Parse shortcut like "cmd+c" -> kd:cmd then kp:c then ku:cmd
        IFS='+' read -ra KEYS <<< "$CONTENT"
        
        # macOS bash 3.2 doesn't support negative indexing like KEYS[-1]
        last_idx=$((${#KEYS[@]} - 1))
        LAST_KEY="${KEYS[$last_idx]}"
        
        MODIFIERS=()
        for ((i=0; i<$last_idx; i++)); do
            MODIFIERS+=("${KEYS[$i]}")
        done
        
        MOD_STR=$(IFS=','; echo "${MODIFIERS[*]}")
        
        if [ ${#MODIFIERS[@]} -gt 0 ]; then
            # Check if last key is a single character (type it) or a special key (press it)
            if [ ${#LAST_KEY} -eq 1 ]; then
                # Use t: for characters (like t:v)
                cliclick "kd:${MOD_STR}" "t:${LAST_KEY}" "ku:${MOD_STR}"
            else
                # Use kp: for special keys (like kp:return)
                cliclick "kd:${MOD_STR}" "kp:${LAST_KEY}" "ku:${MOD_STR}"
            fi
        else
            if [ ${#LAST_KEY} -eq 1 ]; then
                 cliclick "t:${LAST_KEY}"
            else
                 cliclick "kp:${LAST_KEY}"
            fi
        fi
        echo "✅ Shortcut: ${CONTENT}"
        ;;
    *)
        echo "Unknown action: $ACTION" >&2
        exit 1
        ;;
esac
