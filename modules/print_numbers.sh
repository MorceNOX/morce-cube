#!/usr/bin/env bash
#
#   MorceCube™ - A terminal experience for your Rubik's Cube solves!
#   Copyright © 2026 Amilcar Antonio Mesquita Rizk
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.
#


# Function to print a number using ASCII art
print_number() {
    local number="$1"
    
    # Validate input
    if ! [[ "$number" =~ ^[0-9:.,[:space:]]+$ ]]; then
        echo "Error: Input must contain only digits, dot, comma, space and colon." >&2
        return 1
    fi
    
    # Define each digit's ASCII art (12 lines each)
    # We'll read the ASCII art from a string, carefully formatted
    
    # Create arrays for each digit's 12 lines of ASCII art
    
    # 0
    zero=(
        "           "
        "  ░████    "
        " ░██ ░██   "
        "░██ ░████  "
        "░██░██░██  "
        "░████ ░██  "
        " ░██ ░██   "
        "  ░████    "
        "           "
        "           "
        "           "
        "           "
        "           "
    )
    
    # 1
    one=(
        "           "
        "  ░██      "
        "░████      "
        "  ░██      "
        "  ░██      "
        "  ░██      "
        "  ░██      "
        "░██████    "
        "           "
        "           "
        "           "
        "           "
        "           "
    )
    
    # 2
    two=(
        "           "
        " ░██████   "
        "░██   ░██  "
        "      ░██  "
        "  ░█████   "
        " ░██       "
        "░██        "
        "░████████  "
        "           "
        "           "
        "           "
        "           "
        "           "
    )
    
    # 3
    three=(
        "           "
        " ░██████   "
        "░██   ░██  "
        "      ░██  "
        "  ░█████   "
        "      ░██  "
        "░██   ░██  "
        " ░██████   "
        "           "
        "           "
        "           "
        "           "
        "           "
    )
    
    # 4
    four=(
        "           "
        "   ░████   "
        "  ░██ ██   "
        " ░██  ██   "
        "░██   ██   "
        "░█████████ "
        "     ░██   "
        "     ░██   "
        "           "
        "           "
        "           "
        "           "
        "           "
    )
    
    # 5
    five=(
        "           "
        "░████████  "
        "░██        "
        "░███████   "
        "      ░██  " 
        "░██   ░██  " 
        "░██   ░██  " 
        " ░██████   " 
        "           "
        "           "
        "           "
        "           "
        "           "
    )
    
    # 6
    six=(
        "           "
        " ░██████   "
        "░██   ░██  "
        "░██        "
        "░███████   "
        "░██   ░██  "
        "░██   ░██  "
        " ░██████   "
        "           "
        "           "
        "           "
        "           "
        "           "
    )
    
    # 7
    seven=(
        "           "
        "░█████████ "
        "░██    ░██ "
        "      ░██  "
        "     ░██   "
        "    ░██    "
        "    ░██    "
        "    ░██    "
        "           "
        "           "
        "           "
        "           "
        "           "
    )
    
    # 8
    eight=(
        "           "
        " ░██████   "
        "░██   ░██  "
        "░██   ░██  "
        " ░██████   "
        "░██   ░██  "
        "░██   ░██  "
        " ░██████   "
        "           "
        "           "
        "           "
        "           "
        "           "
    )
    
    # 9
    nine=(
        "           "
        " ░██████   "
        "░██   ░██  "
        "░██   ░██  "
        " ░███████  "
        "      ░██  "
        "░██   ░██  "
        " ░██████   "
        "           "
        "           "
        "           "
        "           "
        "           "
    )

    # .
    dot=(
        "           "
        "           "
        "           "
        "           "
        "           "
        "           "
        "           "
        "    ░██    "
        "           "
        "           "
        "           "
        "           "
        "           "
    )

    # ,
    comma=(
        "           "
        "           "
        "           "
        "           "
        "           "
        "           "
        "           "
        "    ░██    "
        "     ░█    "
        "    ░█     "
        "           "
        "           "
        "           "
    )

   # :
    colon=(
        "           "
        "           "
        "           "
        "           "
        "    ░██    "
        "           "
        "           "
        "    ░██    "
        "           "
        "           "
        "           "
        "           "
        "           "
    )

    # 
    space=(
        "           "
        "           "
        "           "
        "           "
        "           "
        "           "
        "           "
        "           "
        "           "
        "           "
        "           "
        "           "
        "           "
    )
    
    # Now let's print the number
    # Store all lines in an array
    local lines=()
    
    # Initialize lines array
    for ((i=0; i<13; i++)); do
        lines[i]=""
    done
    
    # Process each digit
    for ((i=0; i<${#number}; i++)); do
        local digit="${number:$i:1}"
        local digit_array
        
        case "$digit" in
            0) digit_array=("${zero[@]}") ;;
            1) digit_array=("${one[@]}") ;;
            2) digit_array=("${two[@]}") ;;
            3) digit_array=("${three[@]}") ;;
            4) digit_array=("${four[@]}") ;;
            5) digit_array=("${five[@]}") ;;
            6) digit_array=("${six[@]}") ;;
            7) digit_array=("${seven[@]}") ;;
            8) digit_array=("${eight[@]}") ;;
            9) digit_array=("${nine[@]}") ;;
            .) digit_array=("${dot[@]}") ;;
            :) digit_array=("${colon[@]}") ;;
            ,) digit_array=("${comma[@]}") ;;
            "") digit_array=("${space[@]}") ;;
        esac
        
        # Combine with existing lines
        for ((j=0; j<13; j++)); do
            lines[j]="${lines[j]}${digit_array[j]} "
        done
    done
    
    # Print the result
    for line in "${lines[@]}"; do
        echo "$line"
    done
}

# Main execution
if [ $# -eq 0 ]; then
    echo "Usage: $0 <number>"
    echo "Example: $0 12345"
    exit 1
fi

print_number "$1"
