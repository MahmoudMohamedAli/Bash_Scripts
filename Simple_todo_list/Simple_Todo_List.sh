#!/bin/bash
# Simple to do List Script
# This script allows users to manage a simple todo list by adding, listing, removing, clearing,
# and editing tasks. It uses a text file to store the tasks and provides a command-line interface for interaction.
# It also includes a help message to guide users on how to use the script.
#Author: Mahmoud Elkot
# Date: 2025-07-10
# Define the file name

FILE="todo_list.txt"

# Function to display usage/help
usage() {
    echo "Usage: $0 [option]"
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo "  -a <task>     Add a new task to the todo list"
    echo "  -l            List all tasks in the todo list"
    echo "  -r <task>     Delete a task from the todo list number 'n' -> {1..EOF}"
    echo "  -c            Clear the todo list"
    echo "  -e <n> <task> Edit task number n with new task text"
}

Append_NewTask(){

    if [[ -z "$1" ]]; then
        echo "Error: No task provided to add."
        exit 1
    fi

    echo "$1" >> "$FILE"
    echo "Task '$1' added to the todo list."
}

List_Tasks() {
    if [[ -f "$FILE" ]]; then
        line_count=$(wc -l < "$FILE")
        echo "Current tasks in the todo list:$line_count"
        local count=1
        while IFS= read -r line; do
            echo "$count - $line"
            ((count++))
        done < "$FILE"
    else
        echo "No tasks found. The todo list is empty."
    fi
} 

Remove_Task() {
    if [[ -z "$1" ]]; then
        echo "Error: No task number provided to delete."
        exit 1
    fi

    if [[ ! -f "$FILE" ]]; then
        echo "No tasks found. The todo list is empty."
        exit 1
    fi

   # local line_number=$(( $1 )) # Adjust for zero-based index
    sed -i "${1}d" "$FILE"
    echo "Task number '$1' deleted from the todo list."
}   

Remove_AllTasks() {
    if [[ -f "$FILE" ]]; then
        > "$FILE" # Clear the file
        echo "All tasks have been removed from the todo list."
    else
        echo "No tasks found. The todo list is already empty."
    fi
}

Edit_Tasks() {
    if [[ -z "$1" || -z "$2" ]]; then
        echo "Error: Task number and new task text must be provided."
        exit 1
    fi

    if [[ ! -f "$FILE" ]]; then
        echo "No tasks found. The todo list is empty."
        exit 1
    fi
    sed -i "${1}s/.*/$2/" "$FILE"
    echo "Task number '$1' has been updated to '$2'."
}   

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
    exit 0
fi

# Append new tasks in todo list
if [[ "$1" == "-a" || "$1" == "--append" ]]; then
    Append_NewTask "$2"  
    exit 0
fi

# List down all tasks
if [[ "$1" == "-l" || "$1" == "--list" ]]; then
    List_Tasks 
    exit 0
fi

# Remove task number n
if [[ "$1" == "-r" || "$1" == "--remove" ]]; then
    Remove_Task "$2"
    exit 0
fi

# Remove All task number.
if [[ "$1" == "-c" || "$1" == "--clear" ]]; then
    Remove_AllTasks
    exit 0
fi

# Edit task number n
if [[ "$1" == "-e" || "$1" == "--edit" ]]; then
    Edit_Tasks "$2" "$3"
    exit 0
fi

# Check if the file exists
if [[ -f "$FILE" ]]; then
    usage 
else
    echo "File '$FILE' not found!"
    #Create the file if it doesn't exist
    touch "$FILE"
    echo "A new todo list file has been created: '$FILE'."
    echo "You can now add tasks to your todo list."
fi
