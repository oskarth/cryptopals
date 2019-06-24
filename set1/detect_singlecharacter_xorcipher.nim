import singlebytexorcipher

var f = open("4.txt")
var best = CipherResult(text: "", score: 0, character: '0')
for line in f.lines:
    var res = findbest(line)
    if res.score > best.score:
        best = res
f.close()

echo best