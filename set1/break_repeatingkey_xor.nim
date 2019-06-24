import strutils
import tables
import fixedxor
import base64
import singlebytexorcipher
import repeatingkey_xor

const ex1 = "this is a test"
const ex2 = "wokka wokka!!!"

# XXX: Probably more elegant ways...
const hex_lookup =
    {'0': "0000", '1': "0001", '2': "0010", '3': "0011",
     '4': "0100", '5': "0101", '6': "0110", '7': "0111",
     '8': "1000", '9': "1001", 'A': "1010", 'B': "1011",
     'C': "1100", 'D': "1101", 'E': "1110", 'F': "1111"}.toTable

# Compute Hamming distance, number of differing bits
proc distance(a: string, b:string): int =
    assert len(a) == len(b)
    let res = toHex(fixedxor(a, b))
    var dist = 0
    for i in countup(0,len(res)-1):
        # XXX: Has to be a better way to do this
        for b in hex_lookup[res[i]]:
            if b == '1':
                dist += 1
    return dist

assert(distance("this is a test", "wokka wokka!!!") == 37)


# Let's open file and turn diff

var encrypted_hex = ""
var f = open("6.txt")
for line in f.lines:
    #echo toHex(decode(line))
    encrypted_hex = encrypted_hex & decode(line)
f.close()

echo toHex(encrypted_hex)


# # XXX: Only doing keysize up to 20, since we assume we are repeating at least once
# for keysize in countup(2, 20):
#     let dist = distance(encrypted_hex[0..keysize-1], encrypted_hex[keysize..keysize+keysize-1])
#     let normalized = dist / keysize
#     echo "keysize=", keysize, ": ", normalized

# XXX: Scratch that, keysize 5

# This points to
# keysize=11: 2.636363636363636
# But keysize=12: 2.833333333333333
# Also a candidate, try with 4 blocks?
# keysize=18: 2.944444444444445
# Let's assume keysize=11 for now

# I'm not sure I follow edit distance relevance here though, bits differ less between blocks
# because there's some common information in them? something like this

# XXX: Only doing keysize up to 20, since we assume we are repeating at least once
proc guess_keysize(text: string): int =
    var bestguess_dist = 999.9
    var bestguess = 0

    for keysize in countup(2, 20):
        let dist = distance(text[0..keysize-1], text[keysize..keysize+keysize-1])
        let normalized = dist / keysize
        if normalized < bestguess_dist:
            bestguess_dist = normalized
            bestguess = keysize

    return bestguess

#echo guess_keysize(encrypted_hex)

# Assuming keysize=11
let assumed_keysize = 5
var blocks: seq[string]
for i in countup(0,assumed_keysize-1):
    var bl = ""
    var index = i
    while index <= len(encrypted_hex)-2:
        bl = bl & encrypted_hex[index..index+1]
        index += assumed_keysize-1

    blocks.add(bl)

#var best = CipherResult(text: "", score: 0, character: '0')
#echo findbest(toHex(blocks[0]))
    
var key = ""
for b in blocks:
    var best = CipherResult(text: "", score: 0, character: '0')
    var res = findbest(toHex(b))
    echo res
    key.add(res.character)

echo key

#echo best

#echo toHex(repeated_xorcipher(input, key))
# echo "..."
# echo toHex(encrypted_hex)
# echo repeated_xorcipher(encrypted_hex, key)