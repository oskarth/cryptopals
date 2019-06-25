import strutils
import fixedxor
import base64

const input = "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"
const key = "ICE"

proc repeated_xorcipher*(bs1: string, key: string): string =
    var repeated_character: string
    for i in countup(0, len(bs1)-1):
        #.........................................
        repeated_character.add(char(key[i %% len(key)]))
    fixedxor(bs1, repeated_character)

#echo toHex(repeated_xorcipher(input, key))

# Go from encrypted hex to cleartext
let encrypted_hex = "0B3637272A2B2E63622C2E69692A23693A2A3C6324202D623D63343C2A26226324272765272A282B2F20430A652E2C652A3124333A653E2B2027630C692B20283165286326302E27282F"
#echo repeated_xorcipher(parseHexStr(decode(encode(encrypted_hex))), "ICE")

# Extension: read from file as argument / standard input