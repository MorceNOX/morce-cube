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


print_letter() {
    local letter="$1"
    
    #B
    B=(
        "    "
        "▛▀▖ "
        "▙▄▘ "
        "▌ ▌ "
        "▀▀  "
        "    "
        "    "   
    )   
    
    #D
    D=(
        "    "
        "▛▀▖ "
        "▌ ▌ "
        "▌ ▌ "
        "▀▀  "
        "    "   
        "    "   
    )

    #F
    F=(
        "    "
        "▛▀▘ "
        "▙▄  "
        "▌   "
        "▘   "
        "    "   
        "    "   
    )

    #L
    L=(
        "    "
        "▌   "
        "▌   "
        "▌   "
        "▀▀▘ "
        "    "   
        "    "   
    )

    #R   
    R=(
        "    "  
        "▛▀▖ "
        "▙▄▘ "
        "▌▚  "
        "▘ ▘ "
        "    "   
        "    "   
    )

    #U   
    U=(
        "    "  
        "▌ ▌ "
        "▌ ▌ "
        "▌ ▌ "
        "▝▀  "
        "    "   
        "    "   
    )

    #2   
    TWO=(
        "    "  
        "▞▀▖ "
        " ▗▘ "
        "▗▘  "
        "▀▀▘ "
        "    "   
        "    "
    )
    
    #prime
    prime=(
        "    "
        "▞   "
        "    "
        "    "   
        "    "   
        "    "   
        "    "   
    )

    #space
    space=(
        "    "
        "    "
        "    "
        "    "   
        "    "   
        "    "   
        "    "   
    )  
    
    # Now let's print the string
    # Store all lines in an array
    local lines=()
    
    # Initialize lines array
    for ((i=0; i<7; i++)); do
        lines[$i]=""
    done
    
    # Process each char
    for ((i=0; i<${#letter}; i++)); do
        local char="${letter:$i:1}"
        local char_array
        
        case "$char" in
            "B") char_array=("${B[@]}") ;;
            "D") char_array=("${D[@]}") ;;
            "F") char_array=("${F[@]}") ;;
            "L") char_array=("${L[@]}") ;;
            "R") char_array=("${R[@]}") ;;
            "U") char_array=("${U[@]}") ;;
            "2") char_array=("${TWO[@]}") ;;
            "$(echo "´")" | "'") char_array=("${prime[@]}") ;;
            " ") char_array=("${space[@]}") ;;           
        esac
        
        # Combine with existing lines
        for ((j=0; j<7; j++)); do
            lines[$j]="${lines[$j]}${char_array[$j]} "
        done
    done
    
    # Print the result
    for line in "${lines[@]}"; do
        echo "$line"
    done
}

# Main execution
if [ $# -eq 0 ]; then
    echo "Usage: $0 <string>"
    echo "Example: $0 B F L´ R2 D´ F2"
    exit 1
fi

print_letter "$1"
