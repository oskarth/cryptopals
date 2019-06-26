# Compiles and runs with:
# nim c -d:ssl -r ssl.nim

import strutils
from openssl import getOpenSSLVersion

echo "version: 0x" & $getOpenSSLVersion().toHex()

const SHA1Len = 20

# XXX: Hacky, specifying version number manually to find shared library
# Corresponds to https://github.com/openssl/openssl/blob/master/include/openssl/sha.h#L44
proc SHA1(d: cstring, n: culong, md: cstring = nil): cstring {.cdecl, dynlib: "libssl.so.1.1", importc.}

proc SHA1(s: string): string =
    result = ""
    var s = SHA1(s.cstring, s.len.culong)
    for i in countup(0, SHA1Len-1):
        result.add s[i].BiggestInt.toHex(2).toLower

echo SHA1("Rosetta Code")