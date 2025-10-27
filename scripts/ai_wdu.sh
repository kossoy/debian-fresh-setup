#!/bin/zsh

# Enhanced graphical disk usage display
# Original thanks to bolk http://bolknote.ru/2011/09/14/~3407#07
# Compatible with both bash and zsh

set -eo pipefail

# Configuration
readonly DEFAULT_LIST_LENGTH=10
readonly BAR_WIDTH=40
readonly BAR_CHAR="█"  # Default bar character

# Color codes based on terminal capabilities
declare -a COLORS
if [[ ${TERM:-} =~ 256 || ${TERM_PROGRAM:-} = "iTerm.app" ]]; then
    COLORS=("38;5;34" "38;5;220" "38;5;160")  # 256-color terminal
else
    COLORS=(32 33 31)  # Basic terminal colors
fi

# Print usage information
usage() {
    cat <<EOF
Usage: $(basename "$0") [NUMBER]
Display disk usage in a graphical bar chart format.

Arguments:
  NUMBER    Number of items to display (default: $DEFAULT_LIST_LENGTH)

Example:
  $(basename "$0")      # Show top 10 items
  $(basename "$0") 20   # Show top 20 items
EOF
    exit 1
}

# Print colored progress bar
print_bar() {
    local percent=${1:-0}

    # Read the bar template from stdin
    local bar_template
    IFS= read -r bar_template

    # Validate percent
    if [[ ! "$percent" =~ ^[0-9]+$ ]]; then
        percent=0
    fi

    # Ensure percent is within bounds
    (( percent > BAR_WIDTH )) && percent=$BAR_WIDTH
    (( percent < 0 )) && percent=0

    # Select color based on percentage
    local color_idx=0
    (( percent >= 13 )) && color_idx=1
    (( percent >= 20 )) && color_idx=2
    local color=${COLORS[$color_idx]}

    # Extract the bar character safely
    local bar_char="${BAR_CHAR}"
    if [[ ${#bar_template} -ge 3 ]]; then
        # Try to extract character from the template
        local extracted="${bar_template:2:1}"
        [[ -n "$extracted" ]] && bar_char="$extracted"
    fi

    # Create the progress bar
    local progress=""
    if (( percent > 0 )); then
        progress=$(printf "%${percent}s" | tr ' ' "$bar_char")
    fi

    # Create colored replacement
    local colored_progress="\033[${color}m${progress}\033[0m"

    # Replace in template or create new output
    if [[ -n "$progress" ]]; then
        # Replace the progress portion with colored version
        local output="${bar_template:0:2}${colored_progress}${bar_template:$((2 + percent)):$((BAR_WIDTH - percent))}"
        echo -e "$output${bar_template:$((2 + BAR_WIDTH))}"
    else
        # No progress, just output the template
        echo "$bar_template"
    fi
}

# Display disk usage items with bars
print_items() {
    local list_length=${1:-$DEFAULT_LIST_LENGTH}
    local max_size=""

    # Check if du command is available
    if ! command -v du &> /dev/null; then
        echo "Error: 'du' command not found" >&2
        return 1
    fi

    # Get disk usage data
    local du_output
    if ! du_output=$(du -s .[!.]* * 2>/dev/null | sort -rn | head -n "$list_length"); then
        # Try without hidden files if the glob fails
        du_output=$(du -s * 2>/dev/null | sort -rn | head -n "$list_length")
    fi

    # Process empty results
    if [[ -z "$du_output" ]]; then
        echo "│ No files found in current directory          │"
        return 0
    fi

    # Find maximum size
    max_size=$(echo "$du_output" | head -1 | awk '{print $1}')

    # Ensure max_size is valid
    if [[ -z "$max_size" ]] || [[ "$max_size" -eq 0 ]]; then
        max_size=1  # Prevent division by zero
    fi

    # Display items with bars
    while IFS=$'\t' read -r size item; do
        # Skip empty items
        [[ -z "${item:-}" ]] && continue

        # Calculate percentage
        local percent=$(( (size * BAR_WIDTH) / max_size ))

        # Ensure percent doesn't exceed bar width
        (( percent > BAR_WIDTH )) && percent=$BAR_WIDTH

        # Get human-readable size
        local human_size
        if ! human_size=$(du -hs "$item" 2>/dev/null | cut -f1); then
            human_size="N/A"
        fi

        # Truncate long filenames
        local display_name="$item"
        if (( ${#display_name} > 30 )); then
            display_name="${display_name:0:27}..."
        fi

        # Create and display the bar
        printf "│ ████████████████████████████████████████ \033[0m│ %6s %s\n" \
            "$human_size" "$display_name" | print_bar "$percent"

    done <<< "$du_output"
}

# Simplified version without the problematic tr command
print_items_simple() {
    local list_length=${1:-$DEFAULT_LIST_LENGTH}

    # Get disk usage data (disable pipefail temporarily for glob expansion)
    local du_output
    set +o pipefail
    du_output=$(du -sh .[!.]* * 2>/dev/null | sort -rh | head -n "$list_length")
    set -o pipefail

    if [[ -z "$du_output" ]]; then
        echo "│ No files found in current directory          │"
        return 0
    fi

    # Get max size for scaling
    set +o pipefail
    local max_size
    max_size=$(du -s .[!.]* * 2>/dev/null | sort -rn | head -1 | awk '{print $1}')
    set -o pipefail
    [[ -z "$max_size" || "$max_size" -eq 0 ]] && max_size=1

    # Initialize colors
    local color_green color_yellow color_red color_reset
    
    # Only use colors if outputting to a terminal
    if [[ -t 1 ]] || [[ "${FORCE_COLOR:-}" == "1" ]]; then
        # Try 256-color mode if supported, otherwise fall back to 8-color
        if [[ ${TERM:-} =~ 256color ]] || [[ ${COLORTERM:-} =~ (truecolor|24bit) ]]; then
            # 256-color mode
            color_green=$'\033[38;5;34m'
            color_yellow=$'\033[38;5;220m'
            color_red=$'\033[38;5;160m'
            color_reset=$'\033[0m'
        else
            # Basic 8-color mode (more compatible)
            color_green=$'\033[32m'
            color_yellow=$'\033[33m'
            color_red=$'\033[31m'
            color_reset=$'\033[0m'
        fi
    else
        # No colors for non-terminal output
        color_green=""
        color_yellow=""
        color_red=""
        color_reset=""
    fi

    # Display each item
    while IFS=$'\t' read -r human_size item; do
        [[ -z "${item:-}" ]] && continue

        # Get numeric size for percentage calculation
        local size=$(du -s "$item" 2>/dev/null | awk '{print $1}')
        [[ -z "$size" ]] && size=0
        local percent=$(( (size * BAR_WIDTH) / max_size ))
        (( percent > BAR_WIDTH )) && percent=$BAR_WIDTH

        # Select color
        local bar_color="$color_green"
        (( percent >= 13 )) && bar_color="$color_yellow"
        (( percent >= 20 )) && bar_color="$color_red"

        # Create bar
        local filled_bar=""
        local empty_bar=""
        if (( percent > 0 )); then
            filled_bar=$(printf "%${percent}s" | sed 's/ /█/g')
        fi
        if (( BAR_WIDTH - percent > 0 )); then
            empty_bar=$(printf "%$((BAR_WIDTH - percent))s" | sed 's/ /░/g')
        fi

        # Truncate filename if needed
        local display_name="$item"
        if (( ${#display_name} > 30 )); then
            display_name="${display_name:0:27}..."
        fi

        # Output with color
        printf "│ ${bar_color}%-${BAR_WIDTH}s${color_reset} │ %6s %s\n" \
            "${filled_bar}${empty_bar}" "$human_size" "$display_name"

    done <<< "$du_output"
}

# Main function
main() {
    local list_length=$DEFAULT_LIST_LENGTH

    # Parse arguments
    if [[ ${1:-} ]]; then
        if [[ "$1" == "-h" || "$1" == "--help" ]]; then
            usage
        fi

        if [[ ! "$1" =~ ^[0-9]+$ ]]; then
            echo "Error: Argument must be a positive number" >&2
            usage
        fi

        list_length=$1

        if (( list_length < 1 || list_length > 100 )); then
            echo "Error: Number must be between 1 and 100" >&2
            exit 1
        fi
    fi

    # Check if we're in a readable directory
    if [[ ! -r "." ]]; then
        echo "Error: Cannot read current directory" >&2
        exit 1
    fi

    # Display the chart
    echo "┌──────────────────────────────────────────┐"
    print_items_simple "$list_length"  # Using simplified version
    echo "└──────────────────────────────────────────┘"
}

# Run main function (compatible with both bash and zsh)
if [[ -n "${BASH_SOURCE[0]}" ]]; then
    # Running in bash
    [[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
elif [[ -n "${ZSH_VERSION}" ]]; then
    # Running in zsh - check if being sourced
    [[ "${(%):-%x}" == "${0}" ]] && main "$@"
else
    # Other shells - just run it
    main "$@"
fi
# vim: set ts=4 sw=4 et: