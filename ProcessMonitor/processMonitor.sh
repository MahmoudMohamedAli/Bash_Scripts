#!/bin/bash
# Process Monitor Script
# This script monitors system processes, allows killing processes, and provides real-time monitoring.
#Author: Mahmoud Elkot
# Date: 2025-07-10
CONFIG_FILE="$(dirname "$0")/processMonitor.conf"

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Config file not found: $CONFIG_FILE"
    declare Update_Interval=5
    declare CPU_THRESHOLD=50   # 1. Set the CPU usage threshold (%)
    declare MEM_THRESHOLD=50   # 2. Set the memory usage threshold (%)
    declare LOG_FILE = "$(dirname "$0")/processMonitor.log"
fi
echo "log file is $LOG_FILE"

process_statistics() {
    echo "PPID    PID    %CPU    %MEM    COMMAND    USER"
    ps -eo ppid,pid,%cpu,%mem,comm,user
}

Kill_Process() {
    if [[ -z "$1" ]]; then
        echo "Error: No PID provided to kill."
        exit 1
    fi

    if kill "$1"; then
        echo "Process $1 killed successfully."
        # Log the killed process
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Process $1 killed." >> "$LOG_FILE"
    else
        echo "Failed to kill process $1."
    fi
}   

Process_info() {
    if [[ -z "$1" ]]; then
        echo "Error: No PID provided."
        exit 1
    fi
    echo "Info for process $1:"
    ps -p "$1" -o user,ppid,pid,%cpu,%mem,comm
}

RealTimeMonitor() {
    echo "Real-time process monitoring (Press Ctrl+C to stop):"
    while true; do
        clear
        process_statistics
        sleep $Default_Interval
    done
}

SearchProcess() {
    if [[ -z "$1" ]]; then
        echo "Error: No search term provided."
        exit 1
    fi

    echo "Searching for processes matching '$1':"
    ps aux | grep "$1" | grep -v grep

}   

ResourceUsageAlert() {

    echo "Checking for processes exceeding resource thresholds..."

    # 3. List all processes with their PID, command name, CPU%, and MEM%
    ps -eo pid,comm,%cpu,%mem --no-headers | while read pid comm cpu mem; do

        # 4. Remove decimal part for integer comparison
        cpu_int=${cpu%.*}
        mem_int=${mem%.*}

        # 5. If CPU usage is above threshold, print alert
        if (( cpu_int > CPU_THRESHOLD )); then
            alert="ALERT: Process '$comm' (PID $pid) is using high CPU: $cpu%"
            echo "$alert"
            echo "$(date '+%Y-%m-%d %H:%M:%S') - $alert" >> "$LOG_FILE"
        fi

        # 6. If MEM usage is above threshold, print alert
        if (( mem_int > MEM_THRESHOLD )); then
            alert="ALERT: Process '$comm' (PID $pid) is using high MEM: $mem%"
            echo "$alert"
            # 7. Log the alert to a file
            # Append the alert to the log file
             echo "$(date '+%Y-%m-%d %H:%M:%S') - $alert" >> "$LOG_FILE"
        fi
    done
}


InteractiveMenu() {
    echo "Process Monitor Menu:"
    echo "1. View Process Statistics"
    echo "2. Kill a Process"
    echo "3. Get Process Info"
    echo "4. Real-time Monitoring"
    echo "5. Search for a Process"
    echo "6. Resource Usage Alert"
    echo "7. Exit"

    read -p "Choose an option: " choice

    case $choice in
        1) process_statistics ;;
        2) read -p "Enter PID to kill: " pid; Kill_Process "$pid" ;;
        3) read -p "Enter PID to get info: " pid; Process_info "$pid" ;;
        4) RealTimeMonitor ;;
        5) read -p "Enter search term: " term; SearchProcess "$term" ;;
        6) ResourceUsageAlert ;;
        7) exit 0 ;;
        *) echo "Invalid option, please try again." ;;
    esac
}   

# Main script execution
InteractiveMenu
