# uuid
echo UUID
echo UUID 4

first=$(dd if=/dev/random count=6 bs=1 2> /dev/null)

byte7=$(dd if=/dev/random count=1 bs=1 2> /dev/null) 
echo " $((byte7))"
byte7=$((0b$byte7 & 0b00001111))
byte7=$((0b$byte7 | 0b01000000))

byte8=$(dd if=/dev/random count=1 bs=1 2> /dev/null)

byte9=$(dd if=/dev/random count=1 bs=1 2> /dev/null) 
byte9=$(($byte9 & 0b00111111))
byte9=$(($byte9 | 0b10000000))

last=$(dd if=/dev/random count=7 bs=1 2> /dev/null)

result=$(( (first << 2 ** 10) | (byte7 << 2 ** 9) | (byte8 << 2 ** 8) | \
(byte9 << 2 ** 7) | last))
