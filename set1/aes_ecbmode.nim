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

# XXX: AES key type: https://github.com/openssl/openssl/blob/master/include/openssl/aes.h#L27-L41
# Unsigned long (if AES_LONG is set) or unsigned int of 'rd_key[4 * (AES_MAXNR + 1)]'
# where AES_MAXNR appears to be 14, so that's rd_key[60], and then 'int rounds'

# XXX: Like this maybe?
# XXX: It shuld be internal though
type
    rd_key = array[0..60, cint]

type
    aes_key_st {.importc, header: "<openssl/aes.h>".} = object
        rd_key: rd_key
        rounds: cint

# type
#     AESKey = aes_key_st
type
    AES_KEY {.importc, header: "<openssl/aes.h>".} = aes_key_st
# type
#     AES_KEY = ptr aes_key_st

#type
#    AES_KEY {.importc, header: "<openssl/aes.h>".} = object

# Want AES_decrypt too.
#
# void AES_ecb_encrypt(const unsigned char *in, unsigned char *out,
# const AES_KEY *key, const int enc);
# NOTE: Need to rename in and out to in1 and out due to reserved keywords.
# XXX: Maybe no need to rename variable names if they are in the same order?
proc AES_ecb_encrypt(in1: cstring, out1: cstring, aes_key: AES_KEY, enc: cint): cstring
    {.cdecl, dynlib: "libssl.so.1.1", header: "<openssl/aes.h>", importc.}

# Easiest way: use OpenSSL::Cipher and give it AES-128-ECB as the cipher.
# AES ECB
# https://github.com/openssl/openssl/blob/master/include/openssl/aes.h#L53-L54

const key = "YELLOW SUBMARINE"

var testarray: rd_key

#type AESKeyPtr* = ref AES_KEY
#type AESKeyPtr* = ptr AES_KEY
#type AESKeyPtr* = ptr aes_key_st


#let testkey: AES_KEY = AES_KEY(rd_key: testarray, rounds: 0)
#var testkey: AESKeyPtr # = AESKeyPtr(rd_key: testarray, rounds: 0)
var testkey: AES_KEY = AES_KEY(rd_key: testarray, rounds: 0)

#let testkey: AES_KEY = AES_KEY("err")

# XXX
#echo testkey

echo AES_ecb_encrypt("hello", "XXX", testkey, 0)

# XXX: This error
# /home/oskarth/git/cryptopals/set1/openssl/aes.h:54:37: note: expected ‘const AES_KEY *’ {aka ‘const struct aes_key_st *’} but argument is of type ‘AES_KEY’ {aka ‘struct aes_key_st’}
#                      const AES_KEY *key, const int enc);
#                      ~~~~~~~~~~~~~~~^~~

# Want a pointer to AES_KEY


# XXX: Try using const EVP_CIPHER *EVP_aes_192_ecb(void);

# TODO: I should probably write this in C first so I'm clear about C code that should be generated
# Some thing about FFI and pointers and structs I'm missing here
# Can also try CLI for easy mode
# And EVP_CIPHER use as well, perhaps thats correct
# So that's 3 tracks