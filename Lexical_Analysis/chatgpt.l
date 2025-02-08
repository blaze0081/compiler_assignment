%{
/* --- C Declarations and helper routines --- */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_ID_LEN 100
#define MAX_SYMBOLS 1000

/* A simple symbol structure for variables declared in the VarDecl block */
typedef struct Symbol {
    char name[MAX_ID_LEN];
    char type[10]; /* "int" or "char" */
} Symbol;

Symbol symbols[MAX_SYMBOLS];
int symbolCount = 0;  /* number of declared variables */
int inVarDecl = 0;   /* flag for variable declaration section */

/* Check if a string is a keyword */
int isKeyword(const char *str) {
    const char *keywords[] = {
        "int", "float", "if", "else", "while", "for", "main",
        "begin", "end", "input", "output", "program", "VarDecl", "inc", "dec"
    };
    int numKeywords = sizeof(keywords) / sizeof(keywords[0]);
    for (int i = 0; i < numKeywords; i++) {
        if (strcmp(str, keywords[i]) == 0)
            return 1;
    }
    return 0;
}

/* Add variable to symbol table */
void addSymbol(const char *name, const char *type) {
    /* Check for duplicate definition */
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbols[i].name, name) == 0) {
            printf("Lexical Error: Variable '%s' defined more than once\n", name);
            return;
        }
    }
    
    /* Check if keyword is used as variable */
    if (isKeyword(name)) {
        printf("Lexical Error: Keyword '%s' cannot be used as a variable\n", name);
        return;
    }
    
    /* Check underscore count */
    int underscoreCount = 0;
    for (int i = 0; name[i] != '\0'; i++) {
        if (name[i] == '_')
            underscoreCount++;
    }
    if (underscoreCount > 1) {
        printf("Lexical Error: Invalid variable name '%s' (more than one underscore)\n", name);
        return;
    }
    
    strcpy(symbols[symbolCount].name, name);
    strcpy(symbols[symbolCount].type, type);
    symbolCount++;
    printf("DECLARED VARIABLE: %s of type %s\n", name, type);
}

/* Check if variable is declared */
int isDeclared(const char *name) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbols[i].name, name) == 0)
            return 1;
    }
    return 0;
}

/* Validate integer constant */
void validateIntConstant(const char *text) {
    int len = strlen(text);
    if (len < 5) {
        printf("Lexical Error: Invalid integer constant format '%s'\n", text);
        return;
    }
    
    char inner[256];
    strncpy(inner, text+1, len-2);
    inner[len-2] = '\0';
    
    char *comma = strchr(inner, ',');
    if (!comma) {
        printf("Lexical Error: Missing comma in integer constant '%s'\n", text);
        return;
    }
    
    *comma = '\0';
    char *value = inner;
    char *base = comma + 1;
    
    while(isspace(*value)) value++;
    while(isspace(*base)) base++;
    char *endPtr = base + strlen(base) - 1;
    while(endPtr > base && isspace(*endPtr)) { *endPtr = '\0'; endPtr--; }
    
    if (strlen(value) == 0 || strlen(base) == 0) {
        printf("Lexical Error: Missing value or base in integer constant '%s'\n", text);
        return;
    }
    
    int baseNum = atoi(base);
    if (baseNum != 2 && baseNum != 8 && baseNum != 10) {
        printf("Lexical Error: Invalid base '%s' in integer constant '%s'\n", base, text);
        return;
    }
    
    for (int i = 0; value[i] != '\0'; i++) {
        if (!isdigit(value[i])) {
            printf("Lexical Error: Non-digit character in integer constant '%s'\n", text);
            return;
        }
        int digit = value[i] - '0';
        if (baseNum == 8 && digit > 7) {
            printf("Lexical Error: Digit '%c' not allowed in octal constant '%s'\n", value[i], text);
            return;
        }
        if (baseNum == 2 && digit > 1) {
            printf("Lexical Error: Digit '%c' not allowed in binary constant '%s'\n", value[i], text);
            return;
        }
    }
    printf("INTEGER_CONSTANT: %s\n", text);
}
%}

%option noyywrap

/* Regular Expression Definitions */
DIGIT       [0-9]
ID          [a-z]([a-z0-9]*_?[a-z0-9]*)?
INTCONST    \([0-9]+[ \t]*,[ \t]*[0-9]+\)
CHARCONST   \'(\\.|[^\\\'])?\'
STRINGCONST \"([^\"\\]|\\.)*\"
WS          [ \t\n]+
SLCOMMENT   "//".*\n
MLCOMMENT   "/*"([^*]|\*+[^*/])*\*+"/"
VARDECL     \([a-z][a-z0-9]*(_[a-z0-9]+)?,[ \t]*(int|char)\)

%%
{WS}        ;  /* Skip whitespace */
{SLCOMMENT} ;  /* Skip single-line comments */
{MLCOMMENT} ;  /* Skip multi-line comments */

"begin VarDecl:"      { printf("BEGIN_VARDECL\n"); inVarDecl = 1; }
"end VarDecl"         { printf("END_VARDECL\n"); inVarDecl = 0; }

{VARDECL}   {
    char *start = strchr(yytext, '(');
    char *end = strchr(yytext, ')');
    char *comma = strchr(yytext, ',');
    if (start && end && comma) {
        char name[MAX_ID_LEN] = {0};
        char type[10] = {0};
        int nameLen = comma - (start + 1);
        int typeLen = end - (comma + 1);
        strncpy(name, start + 1, nameLen);
        strncpy(type, comma + 1, typeLen);
        name[nameLen] = '\0';
        type[typeLen] = '\0';
        /* Trim whitespace */
        char *ptr = type;
        while (*ptr == ' ' || *ptr == '\t') ptr++;
        memmove(type, ptr, strlen(ptr) + 1);
        ptr = type + strlen(type) - 1;
        while (ptr > type && (*ptr == ' ' || *ptr == '\t')) *ptr-- = '\0';
        addSymbol(name, type);
    }
}

"begin"     { printf("KEYWORD: %s\n", yytext); }
"end"       { printf("KEYWORD: %s\n", yytext); }
"int"       { printf("KEYWORD: %s\n", yytext); }
"float"     { printf("KEYWORD: %s\n", yytext); }
"if"        { printf("KEYWORD: %s\n", yytext); }
"else"      { printf("KEYWORD: %s\n", yytext); }
"while"     { printf("KEYWORD: %s\n", yytext); }
"for"       { printf("KEYWORD: %s\n", yytext); }
"main"      { printf("KEYWORD: %s\n", yytext); }
"input"     { printf("KEYWORD: %s\n", yytext); }
"output"    { printf("KEYWORD: %s\n", yytext); }
"program"   { printf("KEYWORD: %s\n", yytext); }
"VarDecl"   { printf("KEYWORD: %s\n", yytext); }
"inc"       { printf("KEYWORD: %s\n", yytext); }
"dec"       { printf("KEYWORD: %s\n", yytext); }
"print"     { printf("KEYWORD: %s\n", yytext); }
"scan"      { printf("KEYWORD: %s\n", yytext); }

":="        { printf("ASSIGN_OP: %s\n", yytext); }
"+="        { printf("ASSIGN_OP: %s\n", yytext); }
"-="        { printf("ASSIGN_OP: %s\n", yytext); }
"*="        { printf("ASSIGN_OP: %s\n", yytext); }
"/="        { printf("ASSIGN_OP: %s\n", yytext); }
"%="        { printf("ASSIGN_OP: %s\n", yytext); }
"=="        { printf("REL_OP: %s\n", yytext); }
"<="        { printf("REL_OP: %s\n", yytext); }
">="        { printf("REL_OP: %s\n", yytext); }
"<>"        { printf("REL_OP: %s\n", yytext); }
"<"         { printf("REL_OP: %s\n", yytext); }
">"         { printf("REL_OP: %s\n", yytext); }
"="         { printf("REL_OP: %s\n", yytext); }

"+"         { printf("ARITH_OP: %s\n", yytext); }
"-"         { printf("ARITH_OP: %s\n", yytext); }
"*"         { printf("ARITH_OP: %s\n", yytext); }
"/"         { printf("ARITH_OP: %s\n", yytext); }
"%"         { printf("ARITH_OP: %s\n", yytext); }

"("         { printf("SEPARATOR: %s\n", yytext); }
")"         { printf("SEPARATOR: %s\n", yytext); }
"{"         { printf("SEPARATOR: %s\n", yytext); }
"}"         { printf("SEPARATOR: %s\n", yytext); }
";"         { printf("SEPARATOR: %s\n", yytext); }
","         { printf("SEPARATOR: %s\n", yytext); }
":"         { printf("SEPARATOR: %s\n", yytext); }
"\""        { printf("SEPARATOR: %s\n", yytext); }
"@"         { printf("SPECIAL: %s\n", yytext); }

{INTCONST}  { validateIntConstant(yytext); }
{CHARCONST} { printf("CHAR_CONSTANT: %s\n", yytext); }
{STRINGCONST} { printf("STRING_CONSTANT: %s\n", yytext); }

{ID}        {
    if (!inVarDecl && !isDeclared(yytext)) {
        printf("Lexical Error: Variable '%s' used but not declared\n", yytext);
    } else {
        printf("IDENTIFIER: %s\n", yytext);
    }
}

.           { printf("UNKNOWN TOKEN: %s\n", yytext); }

%%

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror("Error opening file");
            exit(1);
        }
        yyin = file;
    }
    yylex();
    return 0;
}