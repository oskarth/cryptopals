import strutils

# NOTE: Maybe declare separate bytestring type?
proc fixedxor*(bs1: string, bs2: string): string =
    assert(len(bs1) == len(bs2), "Not equal length")
    var res: string

    for i in countup(0, len(bs1)-1):
        res.add(char((ord(bs1[i]) xor ord(bs2[i]))))

    return res

# Example
const a = "1c0111001f010100061a024b53535009181c"
const b = "686974207468652062756c6c277320657965"
const c = "746865206b696420646f6e277420706c6179"

let bs1 = parseHexStr(a)
let bs2 = parseHexStr(b)

assert (fixedxor(bs1, bs2) == parseHexStr(c))