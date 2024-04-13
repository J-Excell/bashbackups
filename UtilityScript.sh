#!/usr/bin/env bash

# For each child directory, report how many of each file type there are and
# collective size of each file type
# For each child directory, report the shortest and largest length of a file name
function get_file_types_and_sizes 
{
    cd $1

    # Variable declaration
    declare -A file_sizes
    declare -A file_count
    folder_total_size=0
    
    # For each file add size to collective type size and increment collective type count
    for file in $(find . -maxdepth 1 -type f) 
    do
        this_type=$(file $file | awk '{print $2}')
        this_size=$(stat -c %s $file)
        
        if [ -v file_sizes["$this_type"] ]; then 
            ((file_sizes["$this_type"]+=$this_size))
            ((file_count["$this_type"]+=1))
        else 
            ((file_sizes["$this_type"]=$this_size))
            ((file_count["$this_type"]=1))
        fi
    done

    # For file type in stored file types, display file type total size and count
    # Add total size for this file type to total size for this folder
    for file_type in "${!file_sizes[@]}" 
    do
        ((folder_total_size_kilobytes=${file_sizes[$file_type]}/1000))
        echo "$file_type total size:  ${file_sizes[$file_type]} bytes ($folder_total_size_kilobytes kilobytes)"
        echo "$file_type total count: ${file_count[$file_type]}"
        ((folder_total_size+=folder_total_size_kilobytes))
    done
    echo "Total folder size used: ${folder_total_size}K"

    cd - 1>/dev/null
}

# For each child directory, find the shortest and largest length of a file name
function get_file_names 
{
    cd $1

    echo -n "Largest file name: "
    find . -type f | ls -A | awk '{ print length($0) " characters (" $0 ")" }' | sort -rn | head -n 1
    echo -n "Smallest file name: "
    find . -type f | ls -A | awk '{ print length($0) " characters (" $0 ")" }' | sort -rn | tail -n 1
    
    cd - 1> /dev/null
}

function categorise_directory()
{
    cd _Directory 
    for directory in $(find . -type d)
    do
        # Skip _Directory
        if [ "$directory" == "." ]; then 
            continue 
        fi

        # Section 2 bullet points 1, 2 and 3
        echo $directory
        get_file_types_and_sizes $directory
        get_file_names $directory
        echo 
    done
    cd ..
}

# UUID 1
function uuid_1 
{
    # Get current date and UUID epoch date
    current_date=$(echo "$(date +%s.%N) * 1000000000" | bc)
    uuid_epoch=$(echo "$(date -d "15 Oct 1582 00:00 UTC" +%s.%N) * -1000000000" | bc)

    # Calculate UUID date
    uuid_date=$(echo "($current_date + $uuid_epoch + 1)" | bc) # add 1 for version
    uuid_date=$(echo "ibase=10;obase=16;${uuid_date}" | bc -l)

    # Get MAC address and generate clock sequence
    mac_address=$(ifconfig | awk '/ether/ {print $2}' | tr -d :)
    clock_sequence=$(dd if=/dev/urandom count=2 bs=1 2> /dev/null | xxd -ps)

    # Output UUID 1
    echo "UUID 1: ${uuid_date:0:8}-${uuid_date:8:4}-${uuid_date:12:4}-${clock_sequence}-${mac_address}"
}

#################################### UUID4 #########################################

function uuid_4 
{
    # Generate random numbers
    core_uuid=$(dd if=/dev/urandom count=14 bs=1 2> /dev/null | xxd -ps)
    byte_7=$(dd if=/dev/urandom count=1 bs=1 2> /dev/null | xxd -ps) 
    byte_9=$(dd if=/dev/urandom count=1 bs=1 2> /dev/null | xxd -ps) 

    # Perform binary arithmetic
    byte_7=$((16#$byte_7 & 16#0f | 16#40))
    byte_9=$((16#$byte_9 & 16#3f | 16#80))
    
    # Convert back to hexadecimal
    byte_7=$(echo "ibase=10;obase=16;${byte_7}" | bc -l)
    byte_9=$(echo "ibase=10;obase=16;${byte_9}" | bc -l)

    # Output UUID 4
    echo "UUID 4: ${core_uuid:0:8}-${core_uuid:8:4}-${byte_7,,}${core_uuid:12:2}-${byte_9,,}${core_uuid:14:2}-${core_uuid:16:12}"
}

# entry point
output_to_terminal=0
output_file="test.txt"
while getopts 'ctu:f:' flag 2>>"errorlog.txt"
do
    user=$(whoami)
    current_date_and_time=$(date)
    echo "${current_date_and_time} | ${user} used flags ${flag}" >> log.txt
    case "${flag}" in
        c)  
            categorise_directory > $output_file
            if (($output_to_terminal==1)); then
                cat $output_file
            else
                echo Please see $output_file for your results.
            fi
            ;;
        
        u | uuid)  
            case "${OPTARG}" in 
                1)  
                    echo "Generating a unique UUID version 1"
                    uuid_1
                    ;;
                4)  
                    echo "Generating a unique UUID version 4"
                    uuid_4
                    ;;
                ?)  
                    echo "${OPTARG} is not a supported UUID."
                    ;;
            esac
            ;;

        f)  output_file=$OPTARG;;
        t | terminal)  output_to_terminal=1;;
        ?)  echo Invalid flag. Please try again.;;
    esac
done
