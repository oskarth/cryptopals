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

# XXX: Maybe something is wrong with this one?
proc guess_keysize(ciphertext: string): int =
    var bestguess_dist = 999.9
    var bestguess = 0

    # XXX: Should be upto 40, just temp for ICE key test
    for keysize in countup(2, 40):
        let dist = distance(ciphertext[0..keysize-1], ciphertext[keysize..keysize+keysize-1])
        let normalized = dist / keysize
        #echo "keysize=", keysize, ": ", normalized
        if normalized < bestguess_dist:
            bestguess_dist = normalized
            bestguess = keysize
    return bestguess

proc split_blocks(ciphertext: string, keysize: int): seq[string] =
    var keysized_blocks: seq[string]
    var offset = 0
    while offset <= (len(ciphertext)-1 - keysize):
        var bl = ""
        for i in countup(0, keysize-1):
            bl.add(ciphertext[offset+i])
        keysized_blocks.add(bl)
        offset += keysize
    return keysized_blocks

proc transpose_blocks(keysized_blocks: seq[string], keysize: int): seq[string] =
    var transposed_blocks: seq[string]
    for i in countup(0, keysize-1):
        var bl = ""
        for b in keysized_blocks:
            bl.add(b[i])
        transposed_blocks.add(bl)
    return transposed_blocks

proc findkey(single_key_blocks: seq[string]): string =
    var key = ""
    for b in single_key_blocks:
        # This gives correct result for each key and block:
        #         let text = xorcipher(input, i)
        var res = findbest(b)
        #var res = findbest(toHex(b))
        key.add(res.character)
    return key

proc split_and_transpose_blocks(ciphertext: string, keysize: int): seq[string] =
    let split = split_blocks(ciphertext, keysize)
    let transposed = transpose_blocks(split, keysize)
    return transposed

proc breakcipher_with_keysize(ciphertext: string, keysize: int): string =
    let single_key_blocks = split_and_transpose_blocks(ciphertext, keysize)
    let key = findkey(single_key_blocks)
    echo "****** Key is: ", key
    echo "**** Plaintext is: \n", repeated_xorcipher(ciphertext, key)
    return key
    
proc breakcipher(ciphertext: string): string =
    let guess = guess_keysize(ciphertext)
    let keysize = guess
    let key = breakcipher_with_keysize(ciphertext, keysize)
    return key

# This is some known repeated xor key encrypted hex we can use to sanity check if it is correct
let known_encrypted_hex = "0B3637272A2B2E63622C2E69692A23693A2A3C6324202D623D63343C2A26226324272765272A282B2F20430A652E2C652A3124333A653E2B2027630C692B20283165286326302E27282F"
let known_ciphertext = parseHexStr(known_encrypted_hex)

# Unknown
var file = readFile("6.txt")
let unknown_ciphertext = decode(file)

# If we know the keysize is 3, we can break the known ciphertext
#assert(breakcipher_with_keysize(known_ciphertext, 3) == "ICE")

# Can't guess it correctly yet though
#assert(breakcipher(known_ciphertext) == "ICE")

# for i in countup(4, 40):
#     echo "keysize= ", i, " ", breakcipher_with_keysize(unknown_ciphertext, i)

echo breakcipher_with_keysize(unknown_ciphertext, 29)

#echo repeated_xorcipher(known_ciphertext, "ICE")
echo repeated_xorcipher(unknown_ciphertext, "Terminator X: Bring the noise")