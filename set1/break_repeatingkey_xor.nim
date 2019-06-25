import strutils
import tables
import bitops
import fixedxor
import base64
import singlebytexorcipher
import repeatingkey_xor

const ex1 = "this is a test"
const ex2 = "wokka wokka!!!"

proc distance(a: string, b: string): int =
    assert len(a) == len(b)
    let diff = fixedxor(a,b)
    var dist = 0
    for i in countup(0, len(diff)-1):
        dist += countSetBits(ord(diff[i]))
    return dist

assert(distance("this is a test", "wokka wokka!!!") == 37)

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

# NOTE: this checks distances pairwise, this works well for real ciphertext
# However, finding keysize for simpler text may fail, probably due to lack of data.
proc guess_keysize(ciphertext: string): int =
    var bestguess_dist = 999.9
    var bestguess = 0
    var scoresTable = initOrderedTable[float, int]()

    for keysize in countup(2, 40):
        let s = keysize
        let blocks = split_blocks(ciphertext, keysize)
        var sum = 0
        var i = 0
        while i <= len(blocks)-2:
            sum += distance(blocks[i], blocks[i+1])
            i += 1
        let average = sum / i
        let normalized = average / float(keysize)
        #echo "keysize=", keysize, " ", normalized
        scoresTable[normalized] = keysize
        if normalized < bestguess_dist:
            bestguess_dist = normalized
            bestguess = keysize

    scoresTable.sort(cmp)
    var count = 0
    for k,v in scoresTable.pairs():
        if v > 0:
            if count < 5:
                echo "keysize ", v, ": ", k
            count += 1
    echo "best guess ", bestguess
    return bestguess

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
        var res = findbest(b)
        key.add(res.character)
    return key

proc split_and_transpose_blocks(ciphertext: string, keysize: int): seq[string] =
    let split = split_blocks(ciphertext, keysize)
    let transposed = transpose_blocks(split, keysize)
    return transposed

proc breakcipher_with_keysize(ciphertext: string, keysize: int): string =
    let single_key_blocks = split_and_transpose_blocks(ciphertext, keysize)
    let key = findkey(single_key_blocks)
    # echo "****** Key is: ", key
    # echo "**** Plaintext is: \n", repeated_xorcipher(ciphertext, key)
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

# Can't guess it correctly without knowing keysize, at least with current function
#assert(breakcipher(known_ciphertext) == "ICE")

# Bruteforce
# for i in countup(4, 40):
#     echo "keysize= ", i, " ", breakcipher_with_keysize(unknown_ciphertext, i)

#echo breakcipher_with_keysize(unknown_ciphertext, 29)

# Works
#let key = breakcipher(unknown_ciphertext)
#echo repeated_xorcipher(unknown_ciphertext, key)