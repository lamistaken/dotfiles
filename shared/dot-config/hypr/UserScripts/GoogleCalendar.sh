#!/bin/bash
# Google Calendar Agenda Viewer for Waybar
# Displays gcalcli agenda from TSV file with clickable links

# Temp files for processing
AGENDA_FILE="/tmp/gcalcli_agenda.tsv"
DISPLAY_FILE="/tmp/gcal_display.txt"
LINKS_FILE="/tmp/gcal_links.txt"
NEXT_EVENT_FILE="/tmp/gcal_next_event.txt"

# Helper function to convert time to minutes
time_to_minutes() {
    local time="$1"
    echo $((10#${time%%:*} * 60 + 10#${time##*:}))
}

# Helper function to determine event status (ongoing, upcoming, or past)
get_event_status() {
    local start_date="$1" start_time="$2" end_time="$3"

    # Future dates are always upcoming
    [[ "$start_date" > "$current_date" ]] && echo "upcoming" && return

    # Past dates should be filtered already
    [[ "$start_date" < "$current_date" ]] && echo "past" && return

    # Today's events need time comparison
    if [[ "$start_date" == "$current_date" && -n "$start_time" && -n "$end_time" ]]; then
        local start_min=$(time_to_minutes "$start_time")
        local end_min=$(time_to_minutes "$end_time")
        local curr_min=$(time_to_minutes "$current_time")

        [[ $curr_min -ge $start_min && $curr_min -lt $end_min ]] && echo "ongoing" && return
        [[ $curr_min -lt $start_min ]] && echo "upcoming" && return
    fi

    echo "upcoming" # Default for all-day events
}

# Check if agenda file exists
if [[ ! -f "$AGENDA_FILE" ]]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >"$DISPLAY_FILE"
    echo "  Calendar data not available" >>"$DISPLAY_FILE"
    echo "  Please ensure your crontab is running with:" >>"$DISPLAY_FILE"
    echo "  gcalcli --nocolor agenda --details conference --details location --tsv > /tmp/gcalcli_agenda.tsv" >>"$DISPLAY_FILE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >>"$DISPLAY_FILE"

    cat "$DISPLAY_FILE" | rofi -dmenu -p "󰃭  Google Calendar" \
        -theme-str 'window {width: 800px;}' \
        -theme-str 'listview {lines: 10;}' \
        -no-custom
    exit 0
fi

# Clear temp files
>"$DISPLAY_FILE"
>"$LINKS_FILE"
echo "-1" >"$NEXT_EVENT_FILE"

# Get current date and time for comparison
current_date=$(date "+%Y-%m-%d")
current_time=$(date "+%H:%M")

# Track the next upcoming event line number
line_count=0

# Use awk to properly parse TSV with empty fields
awk -F'\t' 'NR > 1 && $1 != "" {
    # Fields: 1=start_date, 2=start_time, 3=end_date, 4=end_time, 5=conf_type, 6=conf_link, 7=title, 8=location
    print $1 "|" $2 "|" $4 "|" $6 "|" $7 "|" $8
}' "$AGENDA_FILE" | while IFS='|' read -r start_date start_time end_time conf_link title location; do

    # Skip past events from today (only if they have end time and it has passed)
    if [[ "$start_date" == "$current_date" && -n "$end_time" ]]; then
        end_minutes=$(time_to_minutes "$end_time")
        current_minutes=$(time_to_minutes "$current_time")

        # Skip if meeting has already ended
        if [[ $current_minutes -ge $end_minutes ]]; then
            continue
        fi
    fi

    # Skip events from past dates
    if [[ "$start_date" < "$current_date" ]]; then
        continue
    fi

    # Format the date nicely
    if [[ "$start_date" != "$last_date" ]]; then
        if [[ -n "$last_date" ]]; then
            echo "" >>"$DISPLAY_FILE"
            echo "" >>"$LINKS_FILE"
            ((line_count++))
        fi

        # Convert date format (2025-11-10 -> Monday, Nov 10)
        formatted_date=$(date -d "$start_date" "+%A, %b %d" 2>/dev/null || echo "$start_date")
        echo "━━━━━━━━ $formatted_date ━━━━━━━━" >>"$DISPLAY_FILE"
        echo "" >>"$LINKS_FILE"
        ((line_count++))
        last_date="$start_date"
    fi

    # Determine if this is an all-day event or timed event
    if [[ -z "$start_time" ]]; then
        # All-day event
        echo "  󰃭  $title" >>"$DISPLAY_FILE"
        echo "" >>"$LINKS_FILE"
        ((line_count++))
    else
        # Timed event
        # Format time (13:30 -> 1:30 PM)
        formatted_time=$(date -d "$start_time" "+%l:%M %p" 2>/dev/null | sed 's/^ //' || echo "$start_time")

        # Get event status
        status=$(get_event_status "$start_date" "$start_time" "$end_time")

        # Mark the next upcoming or ongoing event for cursor positioning
        next_event_line=$(cat "$NEXT_EVENT_FILE")
        if [[ $next_event_line -eq -1 && ("$status" == "ongoing" || "$status" == "upcoming") ]]; then
            echo "$line_count" >"$NEXT_EVENT_FILE"
        fi

        # Check if there's a link (conference or location with http)
        link=""
        if [[ -n "$conf_link" && "$conf_link" =~ ^http ]]; then
            link="$conf_link"
        elif [[ -n "$location" && "$location" =~ ^http ]]; then
            # Extract just the first URL from location if it contains multiple
            link=$(echo "$location" | grep -oP 'https?://[^,[:space:]]+' | head -1)
        fi

        # Determine prefix based on status
        if [[ "$status" == "ongoing" ]]; then
            prefix="  🔴 $formatted_time - $title [NOW]"
        else
            prefix="  󰥔  $formatted_time - $title"
        fi

        # Add link indicator if present
        if [[ -n "$link" ]]; then
            echo "$prefix 󰌷" >>"$DISPLAY_FILE"
            echo "$link" >>"$LINKS_FILE"
        else
            echo "$prefix" >>"$DISPLAY_FILE"
            echo "" >>"$LINKS_FILE"
        fi
        ((line_count++))
    fi
done

# Display in rofi and capture selection
rofi_args=(
    -dmenu -i -format i
    -p "󰃭  Google Calendar (click event to open link)"
    -theme-str 'window {width: 900px; height: 900px;}'
    -theme-str 'listview {dynamic: true; spacing: 2px;}'
    -theme-str 'inputbar {enabled: false;}'
    -theme-str 'element {padding: 6px; border-radius: 4px;}'
    -theme-str 'element selected {background-color: rgba(100, 150, 255, 0.2);}'
    -kb-row-down "Down,j"
    -kb-row-up "Up,k"
    -kb-accept-entry "Return,l"
    -kb-cancel "Escape,h"
)

# Add selected row if we found a next event
next_event_line=$(cat "$NEXT_EVENT_FILE")
if [[ $next_event_line -ge 0 ]]; then
    rofi_args+=(-selected-row "$next_event_line")
fi

selected=$(rofi "${rofi_args[@]}" <"$DISPLAY_FILE")

# If user selected something, try to open the link
if [[ -n "$selected" ]]; then
    # Get the link for the selected line (line numbers are 0-indexed in rofi)
    link=$(sed -n "$((selected + 1))p" "$LINKS_FILE")

    if [[ -n "$link" && "$link" =~ ^http ]]; then
        # Open the link in default browser
        xdg-open "$link" &
    fi
fi

# Clean up temp files
rm -f "$DISPLAY_FILE" "$LINKS_FILE" "$NEXT_EVENT_FILE"
