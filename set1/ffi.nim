# Playing around with basic C interop to get a feel for how to use OpenSSL

proc printf(format: cstring): cint {.importc, varargs, header: "stdio.h", discardable.}

proc displayFormatted(format: cstring): cint {.importc: "printf", varargs, header: "stdio.h", discardable.}

printf("My name is %s and I am %d years old!\n", "Ben", 30)

displayFormatted("My name is %s and I am %d years old!\n", "Ben", 30)