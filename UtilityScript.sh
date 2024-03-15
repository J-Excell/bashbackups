#!/usr/bin/env bash
cd _Directory

# ------------------------------------- NOTES ------------------------------------
# Use redirect to log any error messages in error log file?
# >> to append, > to overwrite file
# MS mentions needing to use ls, grep, stat and file
# ls -X sorts files by extension category
# File gets file type
# --------------------------------------------------------------------------------

echo ------------------------------- directories ---------------------------------
echo | ls -la
echo -----------------------------------------------------------------------------
echo $'\n'

##################################################################################

# ---------------------------------- Task 1 --------------------------------------
# For each child directory, report how many of each file type there are and
# collective size of each file type

echo File types and Collective size:
# need to group files - I think grep did this?
echo TO BE IMPLEMENTED
echo $'\n'

# ---------------------------------------------------------------------------------

###################################################################################

# ----------------------------------- Task 2 --------------------------------------
# For each child directory, specify total space used, in human readable format
# took inspiration from listing vs finding in 2.8 finding things NOS workbook

echo Child Directories and space used: $'\n'
ls -shd $(find . -type d)
echo 
# ---------------------------------------------------------------------------------

###################################################################################

# ----------------------------------- Task 3 --------------------------------------
# For each child directory, report the shortest and largest length of a file name
# Sort reverse numerically so largest is first
echo Shortest and largest length of file names:

for DIRECTORY in $(find . -type d)
do
#    if $DIRECTORY = pwd?
    
    cd $DIRECTORY 1> junk.txt
    echo $DIRECTORY
    echo LARGEST:
    find . -type f | ls -A | awk '{print length($0) " " $0 }' | sort -rn | head -n 1
    echo SMALLEST:
    find . -type f | ls -A | awk '{print length($0) " " $0 }' | sort -rn | tail -n 1
    cd - 1> junk.txt # stop listing main directory every time u go back
    echo $'\n'
done
# ---------------------------------------------------------------------------------
