#!/bin/bash
# Outputs JSON for Waybar showing calendar status

AGENDA_FILE="/tmp/gcalcli_agenda.tsv"

# Helper function to convert time to minutes
time_to_minutes() {
    local time="$1"
    echo $((10#${time%%:*} * 60 + 10#${time##*:}))
}

# Helper function to escape JSON strings
json_escape() {
    local string="$1"
    # Escape backslashes first, then quotes
    string="${string//\\/\\\\}"
    string="${string//\"/\\\"}"
    echo "$string"
}

# Get current date and time
current_date=$(date "+%Y-%m-%d")
current_time=$(date "+%H:%M")

# Check for ongoing meetings
ongoing_meeting=""

if [[ -f "$AGENDA_FILE" ]]; then
    while IFS=$'\t' read -r start_date start_time end_date end_time conf_type conf_link title location; do
        # Skip header and empty lines
        [[ "$start_date" == "start_date" || -z "$start_date" ]] && continue

        # Check if meeting is today and has times
        if [[ "$start_date" == "$current_date" && -n "$start_time" && -n "$end_time" ]]; then
            # Convert to minutes
            start_min=$(time_to_minutes "$start_time")
            end_min=$(time_to_minutes "$end_time")
            current_min=$(time_to_minutes "$current_time")

            # Check if currently in meeting
            if [[ $current_min -ge $start_min && $current_min -lt $end_min ]]; then
                ongoing_meeting="$title"
                break
            fi
        fi
    done <"$AGENDA_FILE"
fi

# Output JSON for Waybar
if [[ -n "$ongoing_meeting" ]]; then
    safe_title=$(json_escape "$ongoing_meeting")
    echo "{\"text\": \"🔴\", \"class\": \"meeting-active\", \"tooltip\": \"In meeting: $safe_title\"}"
else
    echo "{\"text\": \"󰃭\", \"class\": \"meeting-idle\", \"tooltip\": \"No ongoing meetings\"}"
fi
