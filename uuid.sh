# uuid
echo UUID 4

main=$(dd if=/dev/random count=14 bs=1 2> /dev/null | xxd -ps)

byte7=$(dd if=/dev/random count=1 bs=1 2> /dev/null | xxd -ps)
printf "%x\n" $byte7 
byte7=$((0x$byte7 & 0x0f))
byte7=$((byte7 | 0x40))
echo $($byte7 | xxd -ps)

byte9=$(dd if=/dev/random count=1 bs=1 2> /dev/null | xxd -ps)
printf "%x\n" $byte9
byte9=$((0x$byte9 & 0x3f))
byte9=$((byte9 | 0x80))
printf "%x\n" $byte9

result=${main:0:8}-${main:8:4}-${byte7}${main:12:2}-${byte9}${main:14:2}-${main:16:8}

echo $result
