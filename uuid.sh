# uuid
echo UUID
echo UUID 4

first=$(dd if=/dev/random count=6 bs=1 2> /dev/null | xxd -ps)

byte7=$(dd if=/dev/random count=1 bs=1 2> /dev/null | xxd -ps) 
echo "Hexadecimal representation: ${byte7^^}"
byte7=$(echo "ibase=16;obase=2;${byte7^^}" | bc -l) #convert to binary (works)
echo "Binary representation: ${byte7}"

byte7=$((2#$byte7 & 2#00001111))
byte7=$(echo "ibase=10;obase=2;${byte7^^}" | bc -l) #convert to binary (works)
echo "After and with 0x0f: $byte7"

byte7=$((2#$byte7 | 2#01000000))
byte7=$(echo "ibase=10;obase=2;${byte7^^}" | bc -l) #convert to binary (works)
byte7=$(printf "%08d" "$byte7") #pad with zeros
echo "After or with 0x40: $byte7"

echo $byte7

echo

byte8=$(dd if=/dev/random count=1 bs=1 2> /dev/null | xxd -ps)

byte9=$(dd if=/dev/random count=1 bs=1 2> /dev/null | xxd -ps) 
echo "Hexadecimal representation: ${byte9^^}"
byte9=$(echo "ibase=16;obase=2;${byte9^^}" | bc -l) #convert to binary (works)
byte9=$(printf "%08d" "$byte9") #pad with zeros
echo "Binary representation: ${byte9}"

byte9=$((2#$byte9 & 2#00111111))
byte9=$(echo "ibase=10;obase=2;${byte9^^}" | bc -l) #convert to binary (works)
echo "After and with 0x3f: $byte9"
byte9=$((2#$byte9 | 2#10000000))
byte9=$(echo "ibase=10;obase=2;${byte9^^}" | bc -l) #convert to binary (works)
echo "After or with 0x80: $byte9"
echo $byte9

last=$(dd if=/dev/random count=7 bs=1 2> /dev/null | xxd -ps)

#result=$(( (first << 10) | (byte7 << 9) | (byte8 << 8) | (byte9 << 7) | last))
