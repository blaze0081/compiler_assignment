# Compiler and Tools
FLEX = flex
BISON = yacc
CC = cc

# Source files
LEXER = lexer.l
PARSER = parser.y

# Output files
LEX_OUTPUT = lex.yy.c
YACC_OUTPUT = y.tab.c
YACC_HEADER = y.tab.h

# Default target
all: a.out

# Rule to generate lex.yy.c
$(LEX_OUTPUT): $(LEXER)
	$(FLEX) $(LEXER)

# Rule to generate y.tab.c and y.tab.h
$(YACC_OUTPUT): $(PARSER)
	$(BISON) -d $(PARSER)

# Rule to compile everything
a.out: $(LEX_OUTPUT) $(YACC_OUTPUT)
	$(CC) $(LEX_OUTPUT) $(YACC_OUTPUT) -ll

# Clean rule
clean:
	rm -f a.out $(LEX_OUTPUT) $(YACC_OUTPUT) $(YACC_HEADER)
