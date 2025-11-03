#!/bin/bash

# -------------------------------
# Dependency check
# -------------------------------
DEPENDENCIES=(bash tmux)
MISSING=()

for cmd in "${DEPENDENCIES[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        MISSING+=("$cmd")
    fi
done

if [[ ${#MISSING[@]} -ne 0 ]]; then
    echo "Error: missing dependencies: ${MISSING[*]}"
    echo "Please install them and try again."
    exit 1
fi

# -------------------------------
# File for persistent labels
# -------------------------------
LABEL_FILE="$HOME/.terms_labels"

# Initialize labels
declare -A LABEL
for i in {1..9}; do
    LABEL[$i]="term_$i"
done

# Load saved labels if file exists
if [[ -f "$LABEL_FILE" ]]; then
    while IFS="=" read -r key value; do
        LABEL[$key]="$value"
    done < "$LABEL_FILE"
fi

# Function to save labels
function save_labels() {
    > "$LABEL_FILE"
    for i in {1..9}; do
        echo "$i=${LABEL[$i]}" >> "$LABEL_FILE"
    done
}

# -------------------------------
# Main functions
# -------------------------------
function list_terms() {
    echo "--------------------------"
    echo "Terminal status:"
    for i in {1..9}; do
        if tmux has-session -t term_$i 2>/dev/null; then
            PANE_PID=$(tmux list-panes -t term_$i -F "#{pane_pid}")
            if ps --no-headers --ppid $PANE_PID | grep . >/dev/null; then
                STATUS="Running"
            else
                STATUS="Idle"
            fi
            echo " [$i] ${LABEL[$i]} - $STATUS"
        else
            echo " [$i] ${LABEL[$i]} - Inactive"
        fi
    done
    echo "--------------------------"
}

function open_or_create_term() {
    TERM_NUM="$1"
    if ! [[ "$TERM_NUM" =~ ^[1-9]$ ]]; then
        echo "Invalid terminal number."
        return
    fi

    if ! tmux has-session -t term_$TERM_NUM 2>/dev/null; then
        tmux new-session -d -s term_$TERM_NUM
        echo "Terminal $TERM_NUM created."
    fi

    tmux attach -t term_$TERM_NUM 2>/dev/null || echo "Could not attach to session (may fail as root)."
}

function stop_term() {
    read -p "Enter terminal number (1-9) to stop or 'all' to kill all sessions: " TERM_NUM
    if [[ "$TERM_NUM" == "all" ]]; then
        SESSIONS=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)
        if [[ -z "$SESSIONS" ]]; then
            echo "No tmux sessions to kill."
        else
            for s in $SESSIONS; do
                tmux kill-session -t "$s"
            done
            echo "All tmux sessions killed."
        fi
        return
    fi

    if ! [[ "$TERM_NUM" =~ ^[1-9]$ ]]; then
        echo "Invalid terminal number."
        return
    fi

    if tmux has-session -t term_$TERM_NUM 2>/dev/null; then
        tmux kill-session -t term_$TERM_NUM
        echo "Terminal $TERM_NUM stopped."
    else
        echo "Terminal $TERM_NUM does not exist."
    fi
}

function rename_label() {
    read -p "Enter terminal number (1-9) to rename label: " TERM_NUM
    if ! [[ "$TERM_NUM" =~ ^[1-9]$ ]]; then
        echo "Invalid terminal number."
        return
    fi

    read -p "Enter new label for terminal $TERM_NUM: " NEW_LABEL
    if [[ -z "$NEW_LABEL" ]]; then
        echo "Label cannot be empty."
        return
    fi

    LABEL[$TERM_NUM]="$NEW_LABEL"
    save_labels
    echo "Label for terminal $TERM_NUM changed to ${LABEL[$TERM_NUM]}."
}

# -------------------------------
# Main menu
# -------------------------------
while true; do
    echo
    list_terms
    echo
    echo "Press 1-9 to open terminal, k to stop terminal, r to rename label, q to quit."
    read -n1 -p "> " CHOICE
    echo

    case $CHOICE in
        [1-9]) open_or_create_term "$CHOICE" ;;
        k) stop_term ;;
        r) rename_label ;;
        q) exit 0 ;;
        *) echo "Invalid choice" ;;
    esac
done
