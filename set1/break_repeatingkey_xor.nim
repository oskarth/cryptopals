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

var entirefile = readFile("6.txt")

# Encrypted bytestring with repeating-key crypto, aka ciphertext
#let encrypted_bs = decode(entirefile)

# XXX: Known key, see if we can find it
let encrypted_hex = "0B3637272A2B2E63622C2E69692A23693A2A3C6324202D623D63343C2A26226324272765272A282B2F20430A652E2C652A3124333A653E2B2027630C692B20283165286326302E27282F"
let encrypted_bs = parseHexStr(encrypted_hex)

# Solve it, example
#echo "Solve with right key ", repeated_xorcipher(parseHexStr(encrypted_hex), "ICE")

#echo "len encrypted bs ", len(encrypted_bs), " len hex ", len(toHex(encrypted_bs))

# Each thing here is a byte, hex version is twice as long and each hex is half a byte.
# XXX: Should be upto 40, just temp for ICE key test
for keysize in countup(2, 30):
    # let a = encrypted_bs[0..keysize-1]
    # let b = encrypted_bs[keysize..keysize+keysize-1]
    # echo "*** keysize len ab ", keysize, " ", len(a), " ", len(b)
    # echo "*** index ", 0, "-", keysize-1, " and ", keysize, "-", keysize+keysize-1
    let dist = distance(encrypted_bs[0..keysize-1], encrypted_bs[keysize..keysize+keysize-1])
    let normalized = dist / keysize
    #echo "keysize=", keysize, ": ", normalized

# If we read file correctly (?) now keysize looks much better, keysize=5: 1.2.
# Next one is keysize=3: 2.0

# I'm not sure I follow edit distance relevance here though, bits differ less between blocks
# because there's some common information in them? something like this

proc guess_keysize(text: string): int =
    var bestguess_dist = 999.9
    var bestguess = 0

    # XXX: Should be upto 40, just temp for ICE key test
    for keysize in countup(2, 30):
        let dist = distance(text[0..keysize-1], text[keysize..keysize+keysize-1])
        let normalized = dist / keysize
        if normalized < bestguess_dist:
            bestguess_dist = normalized
            bestguess = keysize

    return bestguess

#echo "Guessing keysize is: ", guess_keysize(encrypted_bs)

# XXX: Both guess is wrong, and even if assuming keysize is 3 it doesn't work
let assumed_keysize = 3
#echo "Assuming keysize is ", assumed_keysize

let keysize = assumed_keysize
let ciphertext = encrypted_bs

# Assuming a byte string is a string
var keysized_blocks: seq[string]

echo type ciphertext
var offset = 0
while offset <= (len(ciphertext)-1 - keysize):
    var bl = "" #XXX
    for i in countup(0, keysize-1):
        bl.add(ciphertext[offset+i])
#    echo "block offset ", offset, " ", toHex(bl)
    keysized_blocks.add(bl)
    offset += keysize
#echo(len(keysized_blocks))
#echo(len(keysized_blocks[0]))

# Ok, now we have blocks of lengt keysize.
# First byte in each block corresponds to a single key

# var first_char_block = ""
# for b in keysized_blocks:
#     first_char_block.add(b[0])
# echo toHex(first_char_block)
# # This should correspond to I
# echo findbest(toHex(first_char_block))
# # This finds I! This is good.

var transposed_blocks: seq[string]
for i in countup(0, keysize-1):
    var bl = ""
    for b in keysized_blocks:
        bl.add(b[i])
    transposed_blocks.add(bl)

# XXX: Now this works, it finds ICE
# echo findbest(toHex(transposed_blocks[0]))
# echo findbest(toHex(transposed_blocks[1]))
# echo findbest(toHex(transposed_blocks[2]))


# XXX: Bad code
# Here atm, check logic
# var blocks: seq[string]
# for i in countup(0,assumed_keysize-1):
#     # Can a block be a string?
#     var bl: string #seq[byte] # = "" # XXX weird
#     var index = i
#     # echo "i ", i
#     while index <= len(encrypted_bs)-2:
#         # if i == 0:
#         #     echo "for block 0 index: ", index
#         # XXX Weird
#         #echo "what's here? ", type encrypted_bs[index..index+1], " ", encrypted_bs[index..index+1]
#         bl.add(encrypted_bs[index..index+1]) #?!?!
#         #bl = bl & encrypted_bs[index..index+1]
#         index += assumed_keysize-1

#     blocks.add(bl)

# echo "blocks len ", len(blocks)
# echo "block0 ", toHex(blocks[0])

# Now use singlexor

#var best = CipherResult(text: "", score: 0, character: '0')

# echo findbest(toHex(blocks[0]))

var key = ""
for b in transposed_blocks:
#    var best = CipherResult(text: "", score: 0, character: '0')
    var res = findbest(toHex(b))
    echo res
    key.add(res.character)

echo key

#echo best

#echo toHex(repeated_xorcipher(input, key))
# echo "..."
# echo toHex(encrypted_hex)
# echo repeated_xorcipher(encrypted_hex, key)