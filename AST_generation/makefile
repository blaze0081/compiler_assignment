# Makefile

# Compiler and tools
CC = cc
FLEX = flex
BISON = bison

# Source files
LEX_FILE = lexer.l
YACC_FILE = parser.y
C_FILES = ast.c

# Generated files
LEX_C = lex.yy.c
YACC_C = parser.tab.c
YACC_H = parser.tab.h

# Output binary
TARGET = a.out

# Build target
all: $(TARGET)

$(TARGET): $(LEX_C) $(YACC_C) $(C_FILES)
	$(CC) -o $(TARGET) $(LEX_C) $(YACC_C) $(C_FILES) -ll

$(LEX_C): $(LEX_FILE)
	$(FLEX) $(LEX_FILE)

$(YACC_C) $(YACC_H): $(YACC_FILE)
	$(BISON) -d $(YACC_FILE)

clean:
	rm -f $(TARGET) $(LEX_C) $(YACC_C) $(YACC_H)

.PHONY: all clean
