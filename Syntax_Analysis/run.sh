flex lexer.l
bison -d parser.y
cc lex.yy.c parser.tab.c syntax.c -ll