validate_timestamp() {
    local input="$1"
    
    # Check if the input is an integer using regex
    if ! [[ $input =~ ^[0-9]+$ ]]; then
        echo "must be a valid unix timestamp"
        return
    fi
    
    # Check if the integer falls within a reasonable range for Unix timestamps
    local min_timestamp=0
    local max_timestamp=$(date -d '2106-02-07' +%s)  # Maximum representable Unix time as of now
    
    if (( input < min_timestamp || input > max_timestamp )); then
        echo "must be a valid unix timestamp"  
    fi
}