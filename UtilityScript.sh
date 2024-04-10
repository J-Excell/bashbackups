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
    if [ "$DIRECTORY" == "." ]; then 
    	continue 
    fi

    echo $DIRECTORY
    declare -A FILES
    declare -A FILECOUNT
    
    for FILE in $(find . -type f) 
    do
        THISFILE=$(file $FILE | awk '{print $2}')
        THISSIZE=$(stat -c %s $FILE)
        
        if [ -v FILES["$THISFILE"] ]; then 
		((FILES["$THISFILE"]+=$THISSIZE))
		((FILECOUNT["$THISFILE"]+=1))
        else 
        	((FILES["$THISFILE"]=$THISSIZE))
        	((FILECOUNT["$THISFILE"]=1))
        fi
    done
    
    totalsize=0
    for FILETYPE in "${!FILES[@]}" 
    do
    	((KSIZE=${FILES[$FILETYPE]}/1024))
    	echo "$FILETYPE size:  ${FILESIZES[$FILETYPE]} bytes ($KSIZE kilobytes)"
    	echo "$FILETYPE count: ${FILECOUNT[$FILETYPE]}"
    	((totalsize+=${FILES[$FILETYPE]}))
    done
    ((totalsize/=1024))
    echo "total size $totalsize K"
    echo
    cd -
    unset FILES
    unset FILECOUNT
done
echo $'\n'

# ---------------------------------------------------------------------------------

###################################################################################

# ----------------------------------- Task 2 --------------------------------------
# For each child directory, specify total space used, in human readable format
# took inspiration from listing vs finding in 2.8 finding things NOS workbook

echo Child Directories and space used:
for DIRECTORY in $(find . -type d)
do 
    cd $DIRECTORY
        if [ "$DIRECTORY" == "." ]; then 
        	continue 
	fi
        echo $DIRECTORY
        ls -s | \
        awk 'BEGIN { totalsize = 0 } { totalsize += $1 } END { print totalsize "K" }'
    cd - 1> /dev/null
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

        cd - 1> /dev/null
    fi
done
# ---------------------------------------------------------------------------------
