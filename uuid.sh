# uuid
echo UUID Generator

# notes
# date +%s returns number of seconds since the epoch
# date +%s.%N adds nanosecond precision

############################# UUID1 #########################################

# Get current date and UUID epoch date
currentdate=$(echo "$(date +%s.%N) * 1000000000" | bc)
uuidepoch=$(echo "$(date -d "15 Oct 1582 00:00 UTC" +%s.%N) * -1000000000" | bc)

# Calculate UUID date
uuiddate=$(echo "($currentdate + $uuidepoch + 1)" | bc) # add 1 for version
uuiddate=$(echo "ibase=10;obase=16;${uuiddate}" | bc -l)

# Get MAC address and generate clock sequence
macaddress=$(ifconfig | awk '/ether/ {print $2}' | tr -d :)
clocksequence=$(dd if=/dev/urandom count=2 bs=1 2> /dev/null | xxd -ps)

# Output UUID 1
echo "UUID 1: ${uuiddate:0:8}-${uuiddate:8:4}-${uuiddate:12:4}-${clocksequence}-${macaddress}"

############################# UUID4 #########################################

# Generate random numbers
main=$(dd if=/dev/urandom count=14 bs=1 2> /dev/null | xxd -ps)
byte7=$(dd if=/dev/urandom count=1 bs=1 2> /dev/null | xxd -ps) 
byte9=$(dd if=/dev/urandom count=1 bs=1 2> /dev/null | xxd -ps) 

# Perform binary arithmetic
byte7=$((16#$byte7 & 16#0f | 16#40))
byte9=$((16#$byte9 & 16#3f | 16#80))

# Convert back to hexadecimal
byte7=$(echo "ibase=10;obase=16;${byte7}" | bc -l)
byte9=$(echo "ibase=10;obase=16;${byte9}" | bc -l)

# Output UUID 4
echo "UUID 4: ${main:0:8}-${main:8:4}-${byte7,,}${main:12:2}-${byte9,,}${main:14:2}-${main:16:12}"
