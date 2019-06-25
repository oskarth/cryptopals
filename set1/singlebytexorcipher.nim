import strutils
import fixedxor

const input = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"
#const common_chars_set = {' ', 'e', 't', 'a', 'o', 'i'}
const common_chars_set = {'e', 't', 'a', 'o', 'i', 'n', ' ', 's', 'h', 'r', 'd', 'l', 'u'}

type
  CipherResult* = object
    text*: string
    score*: int
    character*: char

proc xorcipher*(input: string, iord: int): string =
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

proc findbest*(input: string): CipherResult =
    var best = CipherResult(text: "", score: 0, character: '0')
    for i in countup(0, 255): # 127
        let text = xorcipher(input, i)
        let text_score = score(text)
        # if score(text) > 5:
        #     echo "ord, char, score ", i, ": ", char(i), " ", text_score
        #     # XXX: Even this is wrong! #Doing this wrong
        #     if char(i) == 'I':
        #         echo "'I' special case ", text
        if text_score > best.score:
            best.text = text
            best.score = text_score
            best.character = char(i)
    return best

#echo findbest(input)