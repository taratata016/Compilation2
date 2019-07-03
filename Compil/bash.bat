cls
flex flex.l
bison -d -v bison.y
gcc lex.yy.c tableSymboles.c bison.tab.c -lfl -o pgm.exe
pgm.exe
