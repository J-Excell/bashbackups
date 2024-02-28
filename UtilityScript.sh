#!/usr/bin/env bash
cd _Directory

# -------------------------- DIRECTORIES (for reference) -------------------------
echo directories
echo | ls -la
echo $'\n\n'
# --------------------------------------------------------------------------------


# ---------------------------------- Task 1 --------------------------------------
# For each child directory, report how many of each file type there are and
# collective size of each file type
echo File types and Collective size:
# ls -X sorts files by extension category

COUNT=$( find . -maxdepth 1 -type d | wc -l )
for a in $( seq 1 $((${COUNT}-1)) ) ; do
    echo subdirectory_$a
    ls subdirectory_$a -X 
    echo | ls subdirectory_$a | wc -l 
    echo
done

echo $'\n\n'
# ---------------------------------------------------------------------------------


# ----------------------------------- Task 2 --------------------------------------
# For each child directory, specify total space used, in human readable format
echo Child Directories and space used:
# ls -sh for space used
ls -d | ls -sh
echo 
# ---------------------------------------------------------------------------------


# ----------------------------------- Task 3 --------------------------------------
# For each child directory, report the shortest and largest length of a file name
echo TO BE IMPLEMENTED
# wc -l * | sort -n | head -n 3
# Gets the 3 files with least lines (Pipes and Filters NOS workbook)
echo
# ---------------------------------------------------------------------------------

# Output results to file and option to return to terminal
# think this is done using >> but could be wrong
# also will need a file to write to obviously
