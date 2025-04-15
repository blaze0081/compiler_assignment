flex lexer.l
bison -d parser.y
cc lex.yy.c y.tab.c syntax.c -ll