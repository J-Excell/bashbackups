#!/usr/bin/env bash
cd _Directory

# ------------------------------------- NOTES ------------------------------------
# Use redirect to log any error messages in error log file?
# >> to append, > to overwrite file
# MS mentions needing to use ls, grep, stat and file
# ls -X sorts fileSizes by extension category
# File gets file type, -b for type only
# date +%s returns number of seconds since the epoch
# date +%s.%N adds nanosecond precision
# colon after flag to indicate argument needed (getops line)
# --------------------------------------------------------------------------------

##################################################################################

# ---------------------------------- Task 1 --------------------------------------
#For each child directory, report how many of each file type there are and
#collective size of each file type

function task1 {
    echo File types and Collective size:

    for directory in $(find . -type d) 
    do
        if [ "$directory" == "." ]; then 
            continue 
        fi

        echo $directory
        cd $directory

        declare -A fileSizes
        declare -A fileCount
        totalSize=0
        
        for file in $(find . -maxdepth 1 -type f) 
        do
            thisType=$(file $file | awk '{print $2}')
            thisSize=$(stat -c %s $file)
            
            if [ -v fileSizes["$thisType"] ]; then 
                ((fileSizes["$thisType"]+=$thisSize))
                ((fileCount["$thisType"]+=1))
            else 
                ((fileSizes["$thisType"]=$thisSize))
                ((fileCount["$thisType"]=1))
            fi
        done
        
        for fileType in "${!fileSizes[@]}" 
        do
            ((kSize=${fileSizes[$fileType]}/1024))
            echo "$fileType size:  ${fileSizes[$fileType]} bytes ($kSize kilobytes)"
            echo "$fileType count: ${fileCount[$fileType]}"
            ((totalSize+=kSize))
        done

        echo "total size $totalSize K"
        unset fileSizes
        unset fileCount
        cd - 1> /dev/null
    done
}
# ---------------------------------------------------------------------------------

###################################################################################

# ----------------------------------- Task 2 --------------------------------------
# For each child directory, specify total space used, in human readable format
# took inspiration from listing vs finding in 2.8 finding things NOS workbook
function task2
{
   echo Child Directories and space used:
    for directory in $(find . -type d)
    do 
        if [ "$directory" == "." ]; then 
            continue 
        fi

        echo $directory
        cd $directory
        size=0

        for file in $(find . -maxdepth 1 -type f) 
        do
            ((size+=$(stat -c %s $file)))
        done
        echo $((size/1024))
        cd - 1> /dev/null
    done
}

# ---------------------------------------------------------------------------------

###################################################################################

# ----------------------------------- Task 3 --------------------------------------
# For each child directory, report the shortest and largest length of a file name
function task3 {
echo Shortest and largest length of file names:
for directory in $(find . -type d)
do
    if [ "$directory" == "." ]; then 
        continue 
	fi

    echo $directory
    cd $directory
        
    echo -n "LARGEST file NAME: "
    find . -type f | ls -A | \
        awk '{ print length($0) " characters (" $0 ")" }' | \
        sort -rn | head -n 1
    
    echo -n "SMALLEST file NAME: "
    find . -type f | ls -A | \
        awk '{ print length($0) " characters (" $0 ")" }' | \
        sort -rn | tail -n 1
    echo
    cd - 1> /dev/null
done
}
# ---------------------------------------------------------------------------------

###################################################################################

################################### UUID1 #########################################

function uuid1 {
# Get current date and UUID epoch date
currentDate=$(echo "$(date +%s.%N) * 1000000000" | bc)
uuidEpoch=$(echo "$(date -d "15 Oct 1582 00:00 UTC" +%s.%N) * -1000000000" | bc)

# Calculate UUID date
uuidDate=$(echo "($currentDate + $uuidEpoch + 1)" | bc) # add 1 for version
uuidDate=$(echo "ibase=10;obase=16;${uuidDate}" | bc -l)

# Get MAC address and generate clock sequence
macAddress=$(ifconfig | awk '/ether/ {print $2}' | tr -d :)
clockSequence=$(dd if=/dev/urandom count=2 bs=1 2> /dev/null | xxd -ps)

# Output UUID 1
echo "UUID 1: ${uuidDate:0:8}-${uuidDate:8:4}-${uuidDate:12:4}-${clockSequence}-${macAddress}"
}

#################################### UUID4 #########################################

function uuid4 {
# Generate random numbers
coreUUID=$(dd if=/dev/urandom count=14 bs=1 2> /dev/null | xxd -ps)
byte7=$(dd if=/dev/urandom count=1 bs=1 2> /dev/null | xxd -ps) 
byte9=$(dd if=/dev/urandom count=1 bs=1 2> /dev/null | xxd -ps) 

# Perform binary arithmetic
byte7=$((16#$byte7 & 16#0f | 16#40))
byte9=$((16#$byte9 & 16#3f | 16#80))

# Convert back to hexadecimal
byte7=$(echo "ibase=10;obase=16;${byte7}" | bc -l)
byte9=$(echo "ibase=10;obase=16;${byte9}" | bc -l)

# Output UUID 4
echo "UUID 4: ${coreUUID:0:8}-${coreUUID:8:4}-${byte7,,}${coreUUID:12:2}-${byte9,,}${coreUUID:14:2}-${coreUUID:16:12}"
}

# entry point
while getopts "bnm14" flag
do
    case "${flag}" in
        b) 
            task1 
            ;;
        n) 
            task2
            ;;
        m) 
            task3
            ;;
        1) 
            uuid1
            ;;
        4) 
            uuid4
            ;;
    esac
done
