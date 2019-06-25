import strutils
import fixedxor

const input = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"
const common_chars_set = {'e', 't', 'a', 'o', 'i', 'n', ' ', 's', 'h', 'r', 'd', 'l', 'u'}

type
  CipherResult* = object
    text*: string
    score*: int
    character*: char

proc xorcipher*(bs: string, iord: int): string =
    let character = char(iord)
    var repeated_character: string
    for i in countup(0, len(bs)-1):
        repeated_character.add(character)

    fixedxor(bs, repeated_character)

proc score(input: string): int =
    var score = 0
    for i in countup(0, len(input)-1):
        if input[i] in common_chars_set:
            score += 1
    return score

proc findbest*(bs: string): CipherResult =
    var best = CipherResult(text: "", score: 0, character: '0')
    for i in countup(0, 255):
        let text = xorcipher(bs, i)
        let text_score = score(text)
        if text_score > best.score:
            best.text = text
            best.score = text_score
            best.character = char(i)
    return best