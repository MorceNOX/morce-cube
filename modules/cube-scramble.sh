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


ascii-image-converter -C assets/cube.png
sleep 3

SCRAMBLE_FILE="data/scrambles.txt"
TIMES_FILE="data/times.txt"

N_SCRAMBLES=20
N_TIMES=100

DATA_DIR="data"
DB_FILE="$DATA_DIR"/sessions.db



DIRECTIONS=( "B" "D" "F" "L" "R" "U" )
OPPOSITE_DIR=( "F" "U" "B" "R" "L" "D" )

MODIFIERS=( " " "´" "2" )

KEYPRESS_TIMEOUT=0.02

LOAD_SAVED=false
ao=()


random() {
    local div=$1
    echo $(( (SRANDOM % div) ))
}

create_box() {
    local text="$1"
    local width=$((${#text} + 4))  # Add 4 for padding and borders

    # Top border
    printf "┌"
    for ((i=0; i<width-2; i++)); do
        printf "─"
    done
    printf "┐\n"

    # Text line
    printf "│ %s │\n" $(echo -en "\e[1;32;41m")"$text"$(echo -en "\e[0m")

    # Bottom border
    printf "└"
    for ((i=0; i<width-2; i++)); do
        printf "─"
    done
    printf "┘\n"
}


create_boxes() {
    local words=("$@")

    for word in "${words[@]}"; do
        local width=$((${#word} + 4))

        printf "┌"
        for ((i=0; i<width-2; i++)); do
            printf "─"
        done
        printf "┐\t"
    done
    echo

    for word in "${words[@]}"; do
        printf "│ %s │\t" $(echo -en "\e[1;32;41m")"$word"$(echo -en "\e[0m")
    done
    echo

    for word in "${words[@]}"; do
        local width=$((${#word} + 4))

        printf "└"
        for ((i=0; i<width-2; i++)); do
            printf "─"
        done
        printf "┘\t"
    done
    echo
}


get_strtime() {
    local nanoseconds=$1

    local seconds=$((nanoseconds / 1000000000))
    local minutes=$(( seconds / 60 % 60 ))
    local milliseconds=$(( (nanoseconds % 1000000000) / 1000000 ))

    local str_time="$(printf "%#4d:%02d%s%03d" "$minutes" "$((seconds % 60 ))" "$ds" "$milliseconds")"

    echo "$str_time"

}

min() {
  local a=$1
  local b=$2
  (( a <= b )) && echo "$a" || echo "$b"
}

max() {
  local a=$1
  local b=$2
  (( a >= b )) && echo "$a" || echo "$b"
}

calculate_average() {
    local arr=("$@")
    
    if [ ${#arr[@]} -eq 0 ]; then
        echo 0
        return
    fi
    
    local sum=0
    local count=0
    
    for (( i = 0; i < ${#arr[@]}; i++ )); do
        sum=$(( sum + ${arr[$i]} ))
        count=$(( count + 1 ))
    done
    
    if [ $count -gt 0 ]; then
        local avg=$(( sum / count ))
        echo $avg
    else
        echo 0
    fi
}

calc_ao() {
    local n=$1
    shift
    local arr=("$@")

    if [ ${#arr[@]} -eq 0 ]; then
        echo 0
        return
    fi

    # Take the last n elements
    local last_n=()
    local start_idx=$(( ${#arr[@]} - n ))
    if [ $start_idx -lt 0 ]; then
        start_idx=0
    fi

    for (( i = start_idx; i < ${#arr[@]}; i++ )); do
        last_n+=("${arr[$i]}")
    done

    # If we don't have enough elements to remove min and max, return normal average
    if [ ${#last_n[@]} -lt 3 ]; then
        # Calculate normal average for all elements
        local avg=$(calculate_average "${last_n[@]}")
        echo $avg
        return
    fi

    # Sort the last n elements
    local sorted_arr=( $(printf "%s\n" "${last_n[@]}" | sort -n) )

    # Remove min and max (first and last elements)
    local sum=0
    local count=0
    local middle_start=1
    local middle_end=$(( ${#sorted_arr[@]} - 2 ))

    # Average the middle elements
    for (( i = middle_start; i <= middle_end; i++ )); do
        sum=$(( sum + ${sorted_arr[$i]} ))
        count=$(( count + 1 ))
    done

    # Calculate average
    if [ $count -gt 0 ]; then
        local avg=$(( sum / count ))
        echo $avg
    else
        echo 0
    fi
}


calc_ao_50() {
    local n=$1
    shift
    local arr=("$@")

    if [ ${#arr[@]} -eq 0 ]; then
        echo 0
        return
    fi

    if [ ${#arr[@]} -lt 50 ]; then
        calc_ao ${#arr[@]} ${arr[@]}
        return
    fi

    # Take the last n elements
    local last_n=()
    local start_idx=$(( ${#arr[@]} - n ))
    if [ $start_idx -lt 0 ]; then
        start_idx=0
    fi

    for (( i = start_idx; i < ${#arr[@]}; i++ )); do
        last_n+=("${arr[$i]}")
    done

   # Sort the last n elements
    local sorted_arr=( $(printf "%s\n" "${last_n[@]}" | sort -n) )

    # Remove min and max (first and last elements)
    local sum=0
    local count=0
    local middle_start=3
    local middle_end=$(( ${#sorted_arr[@]} - 4 ))

    # Average the middle elements
    for (( i = middle_start; i <= middle_end; i++ )); do
        sum=$(( sum + ${sorted_arr[$i]} ))
        count=$(( count + 1 ))
    done

    # Calculate average
    if [ $count -gt 0 ]; then
        local avg=$(( sum / count ))
        echo $avg
    else
        echo 0
    fi
}


while :
do
    clear

    prev_prev_dir=""
    prev_dir=""
    MOVEMENTS=( {0..19} )
    FMT_TIMESTAMP=$(LC_TIME="en_GB.UTF-8" date +%4Y-%m-%d_%H:%M:%S)

    for ((i=0; i<20; i++)); do
        n=$(random "${#DIRECTIONS[@]}")
        direction="${DIRECTIONS[$n]}"

        while [[ "$direction" == "$prev_dir" ]] ||
              [[ "$direction" == "$prev_prev_dir" && "$prev_dir" == ${OPPOSITE_DIR[$n]} ]]; do
            n=$(random "${#DIRECTIONS[@]}")
            direction="${DIRECTIONS[$n]}"
        done

        if [ $i -ge 1 ]; then
            prev_prev_dir="$prev_dir"
        fi

        prev_dir="$direction"

        n=$(random "${#MODIFIERS[@]}")
        modifier="${MODIFIERS[$n]}"

        MOVEMENTS[$i]="$direction$modifier"
    done

    # Generate the scramble string
    scramble=""
    for ((i=0; i<20; i++)); do
        scramble="${scramble} ${MOVEMENTS[$i]}"
    done

    scrambleA=""
    for ((i=0; i<7; i++)); do
        scrambleA="${scrambleA} ${MOVEMENTS[$i]}"
    done

    scrambleB=""
    for ((i=7; i<14; i++)); do
        scrambleB="${scrambleB} ${MOVEMENTS[$i]}"
    done

    scrambleC=""
    for ((i=14; i<20; i++)); do
        scrambleC="${scrambleC} ${MOVEMENTS[$i]}"
    done


    # Print the scramble in a box

    echo "         Here is a scramble for the Rubik's Cube:"
    create_box "$scramble"
    echo
    ./modules/print_letters.sh "$scrambleA"
    ./modules/print_letters.sh "$scrambleB"
    ./modules/print_letters.sh "$scrambleC"

    echo
    echo      "─────────────────────────────────────────────────────────────────────────────────────────────────────────────"
    #echo "Are you ready?"
    echo -en "\e[31m"
    echo " ▄▄▄       ██▀███  ▓█████    ▓██   ██▓ ▒█████   █    ██     ██▀███  ▓█████ ▄▄▄      ▓█████▄▓██   ██▓ ██████  "
    echo "▒████▄    ▓██ ▒ ██▒▓█   ▀     ▒██  ██▒▒██▒  ██▒ ██  ▓██▒   ▓██ ▒ ██▒▓█   ▀▒████▄    ▒██▀ ██▌▒██  ██▒      ██ "
    echo "▒██  ▀█▄  ▓██ ░▄█ ▒▒███        ▒██ ██░▒██░  ██▒▓██  ▒██░   ▓██ ░▄█ ▒▒███  ▒██  ▀█▄  ░██   █▌ ▒██ ██░   ▄███  "
    echo "░██▄▄▄▄██ ▒██▀▀█▄  ▒▓█  ▄      ░ ▐██▓░▒██   ██░▓▓█  ░██░   ▒██▀▀█▄  ▒▓█  ▄░██▄▄▄▄██ ░▓█▄   ▌ ░ ▐██▓░   ▀▀    "
    echo " ▓█   ▓██▒░██▓ ▒██▒░▒████▒     ░ ██▒▓░░ ████▓▒░▒▒█████▓    ░██▓ ▒██▒░▒████▒▓█   ▓██▒░▒████▓  ░ ██▒▓░   ██    "
    echo " ▒▒   ▓▒█░░ ▒▓ ░▒▓░░░ ▒░ ░      ██▒▒▒ ░ ▒░▒░▒░ ░▒▓▒ ▒ ▒    ░ ▒▓ ░▒▓░░░ ▒░ ░▒▒   ▓▒█░ ▒▒▓  ▒   ██▒▒▒          "
    echo "  ▒   ▒▒ ░  ░▒ ░ ▒░ ░ ░  ░    ▓██ ░▒░   ░ ▒ ▒░ ░░▒░ ░ ░      ░▒ ░ ▒░ ░ ░  ░ ▒   ▒▒ ░ ░ ▒  ▒ ▓██ ░▒░          "
    echo "  ░   ▒     ░░   ░    ░       ▒ ▒ ░░  ░ ░ ░ ▒   ░░░ ░ ░      ░░   ░    ░    ░   ▒    ░ ░  ░ ▒ ▒ ░░           "
    echo "      ░  ░   ░        ░  ░    ░ ░         ░ ░     ░           ░        ░  ░     ░  ░   ░    ░ ░              "
    echo "                              ░ ░                                                    ░      ░ ░              "
    echo
    echo -en "\e[0m"

    read -p "Press <ENTER> to start the timer, or 's' to list, 'q' to exit... " -r -e t

    case "${t,,}" in
        *s)
          if [[ -f "$SCRAMBLE_FILE" ]]; then
              cat -n SCRAMBLE_FILE | sed G | less -R
          fi
          continue
          ;;
        *q)
          break
          ;;
        *)
          ;;
    esac


    echo
    echo

    start_time=$(date +%s%N)

    # get the decimal separator character
    printf -v ds '%#.1f' 1 && ds=${ds//[0-9]}

    # Start chronometer loop
    while true; do
        current_time=$(date +%s%N)
        elapsed_ns=$((current_time - start_time))

        str_time="$(get_strtime "$elapsed_ns")"

        clear
        echo -en "\e[32m"
        ./modules/print_numbers.sh "$str_time"

        # Check for keypress with a short timeout
        if read -s -t $KEYPRESS_TIMEOUT -n1 -e key; then
            # Key was pressed, stop the chronometer
            break
        fi
    done

    clear
    ./modules/print_numbers.sh "$str_time"

    echo -en "\e[0m"
    echo -en "Stopped!"
    sleep 1
    echo -e "\rYour time: \tScramble: "
    create_boxes "$str_time" "$scramble"

    ao+=( $elapsed_ns )    

    ao5=$(calc_ao 5 "${ao[@]}")
    ao12=$(calc_ao 12 "${ao[@]}")

    if [ ${#ao[@]} -ge 50 ]; then
        ao50=$(calc_ao_50 50 "${ao[@]}")
    fi

    echo "Average time for this session:"
    echo
    printf " ao5: (%#2d) %s\n" $(min 5 ${#ao[@]}) "$(get_strtime "$ao5")"
    printf "ao12: (%#2d) %s\n" $(min 12 ${#ao[@]}) "$(get_strtime "$ao12")"
    if [ ${#ao[@]} -ge 50 ]; then
        printf "ao50: (%#2d) %s\n" $(min 50 ${#ao[@]}) "$(get_strtime "$ao50")"
    fi    

    echo
    read -p "Save this scramble? (Y/n)" -r -e s

    case "${s,,}" in
        *n | no)
          SAVE_SCRAMBLE=false
          ;;
        *)
          SAVE_SCRAMBLE=true
          ;;
    esac

    echo -en "\\033[1A\\033[2K"

    if $SAVE_SCRAMBLE; then

        temp_times_file=$(mktemp)
        echo $elapsed_ns > $temp_times_file

        if [[ -f "$TIMES_FILE" ]]; then
            head -n $(( N_TIMES - 1 )) "$TIMES_FILE" >> "$temp_times_file"
        fi


        # Add to rotating file
        # First, create a temporary file with new scramble at the top
        temp_file=$(mktemp)
        echo -e "$FMT_TIMESTAMP\t$str_time\t$scramble" > "$temp_file"

        # If the file exists, append the existing content (but limit to n-1 lines)
        if [[ -f "$SCRAMBLE_FILE" ]]; then
            head -n $(( N_SCRAMBLES - 1 )) "$SCRAMBLE_FILE" >> "$temp_file"
        fi

        # Move temporary file to final location
        mv "$temp_file" "$SCRAMBLE_FILE"
        mv "$temp_times_file" "$TIMES_FILE"
    fi

    if [[ -f "$TIMES_FILE" ]]; then
        
        IFS=$'\n'
        arr_times=( $(cat $TIMES_FILE) )

        n_times="${#arr_times[@]}"
        n_avg=$(calc_ao $n_times "${arr_times[@]}")
        
        printf " Average Of %#2d: %s\n" $n_times "$(get_strtime "$n_avg")"
        echo
    fi

    if [[ -f "$SCRAMBLE_FILE" ]]; then
        # Show the contents of the file
        echo -e "\rLast 12 scrambles:           "
        echo      "─────────────────────────────────────────────────────────────────────────────────────────────────────────────"

        black=false
        while IFS=$'\n' read -r line; do
            if $black; then
                echo -en "\e[0;37;40m"
                black=false
            else
                echo -en "\e[0m\e[1m"
                black=true
            fi

            printf "%s\n" "$line"

        done < <(head -n 12 "$SCRAMBLE_FILE" | nl)
    fi

    echo -en "\e[0m"
    echo      "─────────────────────────────────────────────────────────────────────────────────────────────────────────────"
    echo

    read -p "Enter any value to continue, or 's' to list, 'q' to exit... " -r -e k

    case "${k,,}" in
        s) 
          if [[ -f "$SCRAMBLE_FILE" ]]; then
              cat -n "$SCRAMBLE_FILE" | sed G | less -R
          fi
          ;;
        *q)
          break
          ;;
        *)
          continue
          ;;
    esac

done

echo
ascii-image-converter -C assets/red-cube.png
