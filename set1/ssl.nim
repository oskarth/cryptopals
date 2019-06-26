from strutils import toHex
from openssl import getOpenSSLVersion

echo "version: 0x" & $getOpenSSLVersion().toHex()

# Compiles and runs with:
# nim c -d:ssl -r ssl.nim
