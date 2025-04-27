flex lexer.l
bison -d parser.y
cc lex.yy.c parser.tab.c symbol.c ast.c -ll