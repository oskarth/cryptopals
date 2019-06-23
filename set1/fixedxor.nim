import strutils

proc fixedxor*(a: string, b: string): string =
    assert len(a) == len(b)
    var res: string
    let bs1 = parseHexStr(a)
    let bs2 = parseHexStr(b)

    for i in countup(0, len(bs1)-1):
        res.add(char((ord(bs1[i]) xor ord(bs2[i]))))

    return res

# Example
const a = "1c0111001f010100061a024b53535009181c"
const b = "686974207468652062756c6c277320657965"
const c = "746865206b696420646f6e277420706c6179"

echo fixedxor(a, b)
assert (fixedxor(a, b) == parseHexStr(c))