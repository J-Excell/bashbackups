#!/usr/bin/env bash
cd _Directory

# ------------------------------------- NOTES ------------------------------------
# Use redirect to log any error messages in error log file?
# >> to append, > to overwrite file
# MS mentions needing to use ls, grep, stat and file
# ls -X sorts files by extension category
# File gets file type, -b for type only
# --------------------------------------------------------------------------------

##################################################################################

# ---------------------------------- Task 1 --------------------------------------
# For each child directory, report how many of each file type there are and
# collective size of each file type

echo File types and Collective size:

for DIRECTORY in $(find . -type d) 
do
    cd $DIRECTORY

    # can you use awk and stat?


    #declare -a FILE_TYPES
    #declare -a FILE_TYPE_SIZE_COUNT
    #for FILE in $(find . -type f)
    #do
    #    THISFILE = File(FILE)
    #    THISSIZE = 
    #    for FILE_TYPE in ${FILE_TYPES[@]}
    #    do
    #        if 
    #done 
    #cd - 1> junk.txt
#done
#echo# $'\n'

# ---------------------------------------------------------------------------------

###################################################################################

# ----------------------------------- Task 2 --------------------------------------
# For each child directory, specify total space used, in human readable format
# took inspiration from listing vs finding in 2.8 finding things NOS workbook

# This still doesn't properly work because the subsubdirectories are bigger than
# the subdirectories?
echo Child Directories and space used:
for DIRECTORY in $(find . -type d)
do 
    cd $DIRECTORY
        if [ "$DIRECTORY" != "." ]; then 
            echo $DIRECTORY
            # find . -type f | \ <- not needed
            ls -sh | \
            awk 'BEGIN { totalsize = 0 } { totalsize += $1 } END { print totalsize "K" } '
        fi
    cd - 1> junk.txt
done
echo 
# ---------------------------------------------------------------------------------

###################################################################################

# ----------------------------------- Task 3 --------------------------------------
# For each child directory, report the shortest and largest length of a file name

echo Shortest and largest length of file names:
for DIRECTORY in $(find . -type d)
do
    if [ "$DIRECTORY" != "." ]; then     
        cd $DIRECTORY 
        echo $DIRECTORY
        
        echo -n "LARGEST FILE: "
        find . -type f | \
            ls -A | \
            awk '{ print length($0) " characters (" $0 ")" }' | \
            sort -rn | \
            head -n 1
        
        echo -n "SMALLEST FILE: "
        find . -type f | \
            ls -A | \
            awk '{ print length($0) " characters (" $0 ")" }' | \
            sort -rn | \
            tail -n 1
        echo 

        cd - 1> junk.txt # stop listing main directory every time u go back
    fi
done
# ---------------------------------------------------------------------------------
