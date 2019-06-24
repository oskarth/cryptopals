import strutils
import tables
import fixedxor

var keysize = 2 # vary upto 40

const ex1 = "this is a test"
const ex2 = "wokka wokka!!!"

# XXX: Probably more elegant ways...
const hex_lookup =
    {'0': "0000", '1': "0001", '2': "0010", '3': "0011",
     '4': "0100", '5': "0101", '6': "0110", '7': "0111",
     '8': "1000", '9': "1001", 'A': "1010", 'B': "1011",
     'C': "1100", 'D': "1101", 'E': "1110", 'F': "1111"}.toTable

# Compute Hamming distance, number of differing bits
# XXX: This should really use fixedxor
proc distance(a: string, b:string): int =
    let ha = toHex(a)
    let hb = toHex(b)
    assert len(ha) == len(hb)
    var dist = 0
    for i in countup(0, len(ha)-1):
        # XXX: Naive
        var anibble = hex_lookup[ha[i]]
        var bnibble = hex_lookup[hb[i]]
        for i in countup(0, 3):
            if anibble[i] != bnibble[i]:
                dist+=1
    return dist

assert(distance("this is a test", "wokka wokka!!!") == 37)