cls
flex flex.l
bison  -d -v bison.y
gcc lex.yy.c Quad.c tableSymboles.c bison.tab.c -lfl -o pgm.exe
pgm.exe
