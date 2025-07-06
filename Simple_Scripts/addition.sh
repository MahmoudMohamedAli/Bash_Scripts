#!/usr/bin/env bash

echo "Welcome to the Addition Script"
declare  Res=0
for num in "$@"; do
    if ! [[ $num =~ ^[0-9]+$ ]]; then
        echo "Error: Please enter a valid number."
        exit 1
    fi
    Res=$((Res + num))
done
echo "The sum of the numbers is: $Res"