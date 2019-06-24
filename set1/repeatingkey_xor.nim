import strutils
import fixedxor

const input = "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"
const key = "ICE"

proc repeated_xorcipher*(bs1: string, key: string): string =
    var repeated_character: string
    for i in countup(0, len(bs1)-1):
        repeated_character.add(char(key[i %% 3]))
    fixedxor(bs1, repeated_character)

echo toHex(repeated_xorcipher(input, key))

# Extension: read from file as argument / standard input