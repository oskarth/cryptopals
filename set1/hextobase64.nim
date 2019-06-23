import strutils
import base64

# XXX: No error handling
proc hexToBase64(s: string): string =
    let bs = parseHexStr(s)
    let encoded = encode(bs)
    return encoded

# Example
const input = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"
const expected = "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"
assert hexToBase64(input) == expected