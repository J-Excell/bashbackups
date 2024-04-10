# uuid
echo UUID Generator

# notes
# date +%s returns number of seconds since the epoch

############################# UUID1 #########################################

currentdate=$(echo "$(date +%s.%N) * 1000000000" | bc) # nanoseconds since epoch
echo $currentdate
uuidepoch=$(echo "$(date -d "15 Oct 1582 00:00 UTC" +%s.%N) * -1000000000" | bc)
echo $uuidepoch
uuiddate=$(echo "($currentdate + $uuidepoch + 1) " | bc) # add 1 for version
echo $uuiddate
uuiddate=$(echo "ibase=10;obase=16;${uuiddate}" | bc -l)
echo "UUID 1: ${uuiddate:0:8}-${uuiddate:8:4}-${uuiddate:12:4}-"
echo "${uuiddate:0:8}"
echo "${uuiddate:8:4}"
echo $uuiddate


############################# UUID4 #########################################

first=$(dd if=/dev/urandom count=6 bs=1 2> /dev/null | xxd -ps)

byte7=$(dd if=/dev/urandom count=1 bs=1 2> /dev/null | xxd -ps) 
#echo "Original byte: ${byte7^^}"
byte7=$((16#$byte7 & 10#15))
byte7=$((10#$byte7 | 10#64))
byte7=$(echo "ibase=10;obase=16;${byte7}" | bc -l) #convert dec back to hex
#echo "After and with 0x0f and or with 0x40: $byte7"

byte8=$(dd if=/dev/urandom count=1 bs=1 2> /dev/null | xxd -ps)

byte9=$(dd if=/dev/urandom count=1 bs=1 2> /dev/null | xxd -ps) 
#echo "Original byte: ${byte9^^}"
byte9=$((16#$byte9 & 10#63))
byte9=$((10#$byte9 | 10#128))
byte9=$(echo "ibase=10;obase=16;${byte9}" | bc -l) #convert dec back to hex
#echo "After and with 0x3f and or with 0x80: $byte9"

last=$(dd if=/dev/urandom count=7 bs=1 2> /dev/null | xxd -ps)

echo "UUID 4: ${first:0:8}-${first:8:4}-${byte7,,}${byte8}-${byte9,,}${last:0:2}-${last:2:12}"
