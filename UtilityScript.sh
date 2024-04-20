#!/usr/bin/env bash

# Called by C flag
function categorise_directory()
{
    cd $starting_directory || return $error_accessing_directory
    
    for directory in $(find . -type d)
    do
        # Skip current directory
        if [ "$directory" == "." ]; then 
            continue 
        fi

        # Section 2 bullet points 1, 2 and 3
        echo $directory
        if ! get_file_types_and_sizes $directory; then
            return $error_accessing_directory
        fi

        if ! get_file_names $directory; then
            return $error_accessing_directory
        fi
        echo 
    done

    cd .. || return $error_accessing_directory
    return 0
}

# For each child directory, report how many of each file type there are and
# collective size of each file type
# For each child directory, report the shortest and largest length of a file name
function get_file_types_and_sizes()
{
    # Try to open the directory, if unable return error accessing directory
    cd $1 || return $error_accessing_directory

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

    # Try to exit the current folder and go back to previous, if unable then return
    # error accessing directory
    cd - 1> /dev/null || return $error_accessing_directory
    return 0
}

# For each child directory, find the shortest and largest length of a file name
function get_file_names()
{
    cd $1 || return $error_accessing_directory

    echo -n "Largest file name: "
    find . -type f | ls -A | awk '{ print length($0) " characters (" $0 ")" }' | \
    sort -rn | head -n 1

    echo -n "Smallest file name: "
    find . -type f | ls -A | awk '{ print length($0) " characters (" $0 ")" }' | \
    sort -rn | tail -n 1
    
    # Try to exit the current folder and go back to previous, if unable then return
    # error accessing directory
    cd - 1> /dev/null || return $error_accessing_directory
    return 0
}

# Handling errors produced by directory categorisation or generating UUID 1.
function handle_error()
{
    case $1 in
        $error_mac_address )
            echo "There was a problem accessing your MAC address."
            echo "Error code: ${error_mac_address}"
        ;;
        $error_accessing_directory )
            echo "There was a problem accessing the directory. Please try again."
            echo "Error code: ${error_accessing_directory}"
            ;;
        *)
            echo "An unknown error has occured. Please try again."
            ;;
    esac
    exit $1
}

# UUID 1
function generate_uuid_1()
{
    # Get current date and UUID epoch date in 100ns intervals
    current_date=$(($(date +%s%N)/100))
    uuid_epoch=$(date -d "1582-10-15 00:00 UTC" +%s)
    uuid_epoch=$(($uuid_epoch * -10000000))

    # Calculate UUID date in 100ns intervals
    uuid_date=$(($current_date + $uuid_epoch))
    uuid_date=$(echo "ibase=10;obase=16;${uuid_date}" | bc -l)

    # Try to get MAC address, if unable return error
    mac_address=$(ip link show | awk '/ether/ {print $2}' | tr -d :)
    if [ -z $mac_address ]; then
        return $error_mac_address
    fi

    # Generate clock sequence
    clock_sequence=$(dd if=/dev/urandom count=2 bs=1 2> /dev/null | xxd -ps)

    # Output UUID 1
    echo "${uuid_date:7:8}-${uuid_date:3:4}-1${uuid_date:0:3}-${clock_sequence}-${mac_address}"
}

# UUID 4
function generate_uuid_4()
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
# Debug mode
# set -x

# Error codes
error_accessing_directory=1
error_mac_address=2

# Directories and files
starting_directory="_Directory"
error_log_file="error_log.log"
standard_output_file="directory_information.txt"
uuid_record_file="uuid_history.txt"

# Varibale initialisation
this_uuid=""

# Flag handling
while getopts 'c:u:' flag 2>> $error_log_file
do
    # Log user, time and the flags they used
    user=$(whoami)
    current_date_and_time=$(date)
    echo "${current_date_and_time} | ${user} used flags ${flag}" >> $error_log_file
    
    # Perform action based on flag
    case "${flag}" in
        c)
            # Categorise the directory (second bullet point)
            echo Categorising directory. Please wait...
            touch "${standard_output_file}"

            # Handle any errors
            if ! categorise_directory > $standard_output_file ; then
                echo error found
                handle_error $?
            fi
            ls
            case "${OPTARG}" in 
                # Output results to terminal
                "terminal" | "t") 
                    cat "$standard_output_file"
                    ;;

                # Only save results to file
                "file" | "f") 
                    echo "Please see $standard_output_file for your results." 
                    ;;

                # Other argument
                *) 
                    echo "Invalid flag. Your results are still available at $standard_output_file." 
                    ;;
            esac 
            ;;

        "u")  
            # Generate either a UUID version 1 or 4
            case "${OPTARG}" in 
                1)  
                    # Generate a UUID version 1
                    echo "Generating a unique UUID version 1"
                    if ! this_uuid=$(generate_uuid_1); then
                        handle_error $?
                    fi

                    # If the UUID has been previously generated, generate a new one
                    if [ -f "$uuid_record_file" ]; then
                        while (grep "$this_uuid" $uuid_record_file)
                        do 
                            echo Error: UUID generated already exists. Generating a new UUID...
                            this_uuid=$(generate_uuid_1)
                        done
                    fi

                    # Output the generated UUID
                    echo "${this_uuid}"

                    # Save the generated UUID to records
                    echo "$(date) | ${this_uuid}" >> $uuid_record_file
                    ;;
                4)  
                    # Generate a UUID version 4
                    echo "Generating a unique UUID version 4"
                    this_uuid=$(generate_uuid_4)

                    # If the UUID has been previously generated, generate a new one 
                    if [ -f "$uuid_record_file" ]; then
                        while (grep "$this_uuid" $uuid_record_file)
                        do 
                            echo Error: UUID generated already exists. Generating a new UUID...
                            this_uuid=$(generate_uuid_4)
                        done
                    fi

                    # Output the generated UUID
                    echo $this_uuid

                    # Save the generated UUID to records
                    echo $this_uuid >> $uuid_record_file
                    ;;
                *)  
                    echo "${OPTARG} is not a supported UUID."
                    ;;
            esac
            ;;
        *)  
            echo "${flag} is an invalid flag. Please try again."
            ;;
    esac
done
