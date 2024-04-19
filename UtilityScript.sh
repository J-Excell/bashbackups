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

# Called by C flag
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
    # Get current date and UUID epoch date in 100ns intervals
    current_date=$(($(date +%s%N)/100))
    uuid_epoch=$(date -d "1582-10-15 00:00 UTC" +%s)
    uuid_epoch=$(($uuid_epoch * -10000000))


    # Calculate UUID date in 100ns intervals
    uuid_date=$(($current_date + $uuid_epoch))
    uuid_date=$(echo "ibase=10;obase=16;${uuid_date}" | bc -l)

    # Get MAC address and generate clock sequence
    mac_address=$(ip link show | awk '/ether/ {print $2}' | tr -d :)
    clock_sequence=$(dd if=/dev/urandom count=2 bs=1 2> /dev/null | xxd -ps)

    # Output UUID 1
    echo "${uuid_date:7:8}-${uuid_date:3:4}-1${uuid_date:0:3}-${clock_sequence}-${mac_address}"
}

# UUID 4
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
    echo "${core_uuid:0:8}-${core_uuid:8:4}-${byte_7,,}${core_uuid:12:2}-${byte_9,,}${core_uuid:14:2}-${core_uuid:16:12}"
}

output_file="test.txt"
while getopts 'c:u:' flag 2>>"errorlog.txt"
do
    # Log user, time and the flags they used
    user=$(whoami)
    current_date_and_time=$(date)
    echo "${current_date_and_time} | ${user} used flags ${flag}" >> log.txt
    
    # Perform action based on flag
    case "${flag}" in
        c)
            # Categorise the directory (second bullet point)
            echo "OPTARG ---${OPTARG}---"
            echo Categorising directory. Please wait...
            categorise_directory > $output_file
            echo done
            case "${OPTARG}" in 
                "terminal" | "t")
                    cat $output_file
                    ;;
                "file")
                    echo Please see $output_file for your results.
                    ;;
                *)
                    echo Invalid flag. Your results are still available at $output_file.
                    ;;
                esac
                ;;

        "u")  
            # Generate a UUID
            case "${OPTARG}" in 
                1)  
                    echo "Generating a unique UUID version 1"
                    this_uuid=$(uuid_1)
                    if [ -f "uuid.txt" ]; then
                        while (grep "$this_uuid" uuid.txt)
                        do 
                            echo Error: UUID generated already exists. Generating a new UUID...
                            this_uuid=$(uuid_1)
                        done
                    fi
                    current_date_and_time=$(date)
                    echo "${this_uuid}"
                    echo "${current_date_and_time} | ${this_uuid}" >> uuid.txt
                    ;;
                4)  
                    echo "Generating a unique UUID version 4"
                    this_uuid=$(uuid_4) 
                    if [ -f "uuid.txt" ]; then
                        while (grep "$this_uuid" uuid.txt)
                        do 
                            echo Error: UUID generated already exists. Generating a new UUID...
                            this_uuid=$(uuid_4)
                        done
                    fi
                    echo $this_uuid
                    echo $this_uuid >> uuid.txt
                    ;;
                *)  
                    echo "${OPTARG} is not a supported UUID."
                    ;;
            esac
            ;;
        *)  
            echo "${OPTARG} is an invalid flag. Please try again."
            ;;
    esac
done
