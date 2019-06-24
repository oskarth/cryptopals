import strutils
import fixedxor

const input = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"
const common_chars_set = {' ', 'e', 't', 'a', 'o', 'i'}

proc xorcipher(input: string, iord: int): string =
    let bs1 = parseHexStr(input)
    let character = char(iord)
    var repeated_character: string
    for i in countup(0, len(bs1)-1):
        repeated_character.add(character)

    fixedxor(bs1, repeated_character)

proc score(input: string): int =
    var score = 0
    for i in countup(0, len(input)-1):
        if input[i] in common_chars_set:
            score += 1
    return score

proc findbest() =
    var best_score = 0
    var best: string
    for i in countup(0, 127):
        let text = xorcipher(input, i)
        let text_score = score(text)
        if text_score > best_score:
            best = text
            best_score = text_score
    echo "Best score found: ", best_score
    echo best

findbest()