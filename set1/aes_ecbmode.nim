# Compiles and runs with:
# nim c -d:ssl -r aes_ecbmode.nim

import strutils
from openssl import getOpenSSLVersion

echo "version: 0x" & $getOpenSSLVersion().toHex()

const SHA1Len = 20

# XXX: Hacky, specifying version number manually to find shared library
# Corresponds to https://github.com/openssl/openssl/blob/master/include/openssl/sha.h#L44
# unsigned char *SHA1(const unsigned char *d, size_t n, unsigned char *md);
proc SHA1(d: cstring, n: culong, md: cstring = nil): cstring
    {.cdecl, dynlib: "libssl.so.1.1", importc.}

proc SHA1(s: string): string =
    result = ""
    var s = SHA1(s.cstring, s.len.culong)
    for i in countup(0, SHA1Len-1):
        result.add s[i].BiggestInt.toHex(2).toLower

echo SHA1("Rosetta Code")

# Want AES_decrypt too.
#
# void AES_ecb_encrypt(const unsigned char *in, unsigned char *out,
# const AES_KEY *key, const int enc);
# TODO: Need to rename in and out to in1 and out due to reserved keywords.
# TODO: AES_KEY and const int
proc AES_ecb_encrypt(in1: cstring, out1: cstring, n: culong, md: cstring = nil): cstring
    {.cdecl, dynlib: "libssl.so.1.1", importc.}

# Easiest way: use OpenSSL::Cipher and give it AES-128-ECB as the cipher.
# AES ECB
# https://github.com/openssl/openssl/blob/master/include/openssl/aes.h#L53-L54

const key = "YELLOW SUBMARINE"