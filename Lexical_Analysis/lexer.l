%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_ID_LEN 100
#define MAX_SYMBOLS 1000

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
        "int", "char", "if", "else", "while", "for", "main",
        "begin", "end", "print", "scan", "program", "VarDecl", "inc", "dec"
    };
    int numKeywords = sizeof(keywords) / sizeof(keywords[0]);
    for (int i = 0; i < numKeywords; i++) {
        if (strcmp(str, keywords[i]) == 0)
            return 1;
    }
    return 0;
}

void addSymbol(const char *name, const char *type) {
    /* Check for duplicate definition */
    printf("(                         Separator\n");
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbols[i].name, name) == 0) {
            printf("%-25s Error: identifier already declared\n", name);
            goto label;
        }
    }
    
    /* Check if keyword is used as variable */
    if (isKeyword(name)) {
        printf("%-25s Error: Keyword is used as an identifier\n", name);
        goto label;
    }
    
    /* Check underscore count */
    int underscoreCount = 0;
for (int i = 0; name[i] != '\0'; i++) {
        if (name[i] == '_')
            underscoreCount++;
    }
    if (underscoreCount > 1) {
        printf("%-25s Error: invalid identifier\n", name);
        goto label;
    }

    else{
        printf("%s                        Identifier\n", name);
        strcpy(symbols[symbolCount].name, name);
        strcpy(symbols[symbolCount].type, type);
        symbolCount++;
    }
    
    
    label:
    printf(",                         Separator\n");
    printf("%s                        Keyword\n", type);
    printf(")                         Separator\n");

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
        printf("%-25s Error: invalid integer constant\n", text);
        return;
    }
    
    char inner[256];
    strncpy(inner, text+1, len-2);
    inner[len-2] = '\0';
    
    char *comma = strchr(inner, ',');
    if (!comma) {
        printf("%-25s Error: invalid integer constant\n", text);
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
        printf("%-25s Error: invalid integer constant\n", text);
        return;
    }
    
    int baseNum = atoi(base);
    if (baseNum != 2 && baseNum != 8 && baseNum != 10) {
        printf("%-25s Error: invalid integer constant\n", text);
        return;
    }
    
    for (int i = 0; value[i] != '\0'; i++) {
        if (!isdigit(value[i])) {
            printf("%-25s Error: invalid integer constant\n", text);
            return;
        }
        int digit = value[i] - '0';
        if (baseNum == 8 && digit > 7) {
            printf("%-25s Error: invalid integer constant\n", text);
            return;
        }
        if (baseNum == 2 && digit > 1) {
            printf("%-25s Error: invalid integer constant\n", text);
            return;
        }
    }
    printf("%-25s Integer constant\n", text);
}

/* Count occurrences of @ in a string */
int countAtSymbols(const char *str) {
    int count = 0;
    char *ptr = strchr(str, '@');
    while (ptr != NULL) {
        count++;
        ptr = strchr(ptr + 1, '@');
    }
    return count;
}

int countCommaSymbols(const char *str) {
    int count = 0;
    char *ptr = strchr(str, ',');
    while (ptr != NULL) {
        count++;
        ptr = strchr(ptr + 1, ',');
    }
    return count;
}

/* Count number of arguments (values after the format string) */
int countArgs(const char *str) {
    int count = 0;
    const char *ptr = str;
    int in_string = 0;
    
    // Skip until after the first string
    while (*ptr) {
        if (*ptr == '"') {
            in_string = !in_string;
            if (!in_string) {
                ptr++;
                break;
            }
        }
        ptr++;
    }
    
    // Count commas outside of strings and constants
    int in_const = 0;
    while (*ptr) {
        if (*ptr == '(') in_const = 1;
        else if (*ptr == ')') in_const = 0;
        else if (*ptr == '"') in_string = !in_string;
        else if (*ptr == ',' && !in_string && !in_const) count++;
        ptr++;
    }
    
    return count + 1;  // Add 1 because commas are one less than arguments
}

int validateIO(const char *text, int is_scan) {
    // Check for semicolon at the end
    size_t len = strlen(text);
    if (text[len-1] != ';') {
        switch(is_scan){
            case 0:
                printf("%-25s  Error: invalid input statement [no semicolon]\n", text);
            case 1:
                printf("%-25s  Error: invalid output statement [no semicolon]\n", text);
        }
        return 0;
    }
    
    // Find the first string
    char *start_quote = strchr(text, '"');
    char *end_quote = start_quote ? strchr(start_quote + 1, '"') : NULL;
    
    if (!start_quote || !end_quote) {
        switch(is_scan){
            case 0:
                printf("%-25s  Error: invalid input statement [incomplete line]\n", text);
            case 1:
                printf("%-25s  Error: invalid output statement [incomplete line]\n", text);
        }
        return 0;
    }
    
    // Extract and check the format string
    size_t format_len = end_quote - start_quote - 1;
    char format_str[256] = {0};
    strncpy(format_str, start_quote + 1, format_len);
    
    int at_count = countAtSymbols(format_str);
    int arg_count = countArgs(text) - 1;  // -1 because first arg is format string
    int comma_count = countCommaSymbols(format_str);

    // print("comma:, %d", comma_count); LEGAL STATEMENT
    if (is_scan && (comma_count != arg_count-1)) {
            printf("%-25s  Error: invalid input statement [comma count does NOT match arguments]\n", text);
        return 0;
    }

    if (at_count != arg_count) {
        switch(is_scan){
            case 0:
                printf("%-25s  Error: invalid input statement [@ count does NOT match argument count]\n", text);
            case 1:
                printf("%-25s  Error: invalid output statement [@ count does NOT match argument count]\n", text);
        }
        return 0;
    }
    
    if (is_scan) {
        // For scan, all arguments must be identifiers
        char *ptr = end_quote + 1;
        while (*ptr) {
            if (*ptr == '(' || *ptr == '\'' || *ptr == '"') {
                printf("%-25s  Error: invalid input statement [invalid declaration]\n", text);
                return 0;
            }
            ptr++;
        }
    }
    
    if (is_scan) {
        printf("%-25s Valid input statements\n", text);
    } else {
        printf("%-25s Valid output statement\n", text);
    }
    
    return 1;
}

%}

%option noyywrap

/* Regular Expression Definitions */
DIGIT       [0-9]
ID          [a-z]([a-z0-9]*_?[a-z0-9]*)?
INTCONST    \([0-9]+[ \t]*,[ \t]*[0-9]*\)
CHARCONST   \'(\\.|[^\\\'])?\'
STRINGCONST \"([^\"\\]|\\.)*\"
WS          [ \t\n]+
SLCOMMENT   "//".*\n
MLCOMMENT   "/*"([^*]|\*+[^*/])*\*+"/"
VARDECL     \([a-z][a-z0-9]*([_]+[a-z0-9]+)?([_]+[a-z0-9]+)?,[ \t](int|char)\)

PRINT_STMT  print[ \t]*\(\"[^\"]*\"([ \t]*,[ \t]*[^,;]*)*[ \t]*\);?
SCAN_STMT   scan[ \t]*\(\"[^\"]*\"([ \t]*,[ \t]*[^,;]*)*[ \t]*\);?


%%
{WS}        ;  /* Skip whitespace */
{SLCOMMENT} ;  /* Skip single-line comments */
{MLCOMMENT} ;  /* Skip multi-line comments */

"begin VarDecl:"      { 
    printf("%-25s Keyword\n", "begin"); 
    printf("%-25s Keyword\n", "VarDecl"); 
    printf("%-25s Separator\n", ":"); 
    inVarDecl = 1; 
}

"end VarDecl"         { 
    printf("%-25s Keyword\n", "end"); 
    printf("%-25s Keyword\n", "VarDecl"); 
    inVarDecl = 0; 
}

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

        addSymbol(name, type);
    }
}

"begin"     { printf("%-25s Keyword\n", yytext); }
"end"       { printf("%-25s Keyword\n", yytext); }
"int"       { printf("%-25s Keyword\n", yytext); }
"char"      { printf("%-25s Keyword\n", yytext); }
"if"        { printf("%-25s Keyword\n", yytext); }
"then"      { printf("%-25s Keyword\n", yytext); }
"else"      { printf("%-25s Keyword\n", yytext); }
"while"     { printf("%-25s Keyword\n", yytext); }
"for"       { printf("%-25s Keyword\n", yytext); }
"main"      { printf("%-25s Keyword\n", yytext); }
"input"     { printf("%-25s Keyword\n", yytext); }
"output"    { printf("%-25s Keyword\n", yytext); }
"program"   { printf("%-25s Keyword\n", yytext); }
"VarDecl"   { printf("%-25s Keyword\n", yytext); }
"inc"       { printf("%-25s Keyword\n", yytext); }
"dec"       { printf("%-25s Keyword\n", yytext); }
"print"     { printf("%-25s Keyword\n", yytext); }
"scan"      { printf("%-25s Keyword\n", yytext); }
"do"        { printf("%-25s Keyword\n", yytext); }
"to"        { printf("%-25s Keyword\n", yytext); }


":="        { printf("%-25s Assignment operator\n", yytext); }
"+="        { printf("%-25s Assignment operator\n", yytext); }
"-="        { printf("%-25s Assignment operator\n", yytext); }
"*="        { printf("%-25s Assignment operator\n", yytext); }
"/="        { printf("%-25s Assignment operator\n", yytext); }
"%="        { printf("%-25s Assignment operator\n", yytext); }
"=="        { printf("%-25s Relational operator\n", yytext); }
"<="        { printf("%-25s Relational operator\n", yytext); }
">="        { printf("%-25s Relational operator\n", yytext); }
"<>"        { printf("%-25s Relational operator\n", yytext); }
"<"         { printf("%-25s Relational operator\n", yytext); }
">"         { printf("%-25s Relational operator\n", yytext); }
"="         { printf("%-25s Relational operator\n", yytext); }

"+"         { printf("%-25s Arithmetic operator\n", yytext); }
"-"         { printf("%-25s Arithmetic operator\n", yytext); }
"*"         { printf("%-25s Arithmetic operator\n", yytext); }
"/"         { printf("%-25s Arithmetic operator\n", yytext); }
"%"         { printf("%-25s Arithmetic operator\n", yytext); }

"("         { printf("%-25s Separator\n", yytext); }
")"         { printf("%-25s Separator\n", yytext); }
"{"         { printf("%-25s Separator\n", yytext); }
"}"         { printf("%-25s Separator\n", yytext); }
";"         { printf("%-25s Separator\n", yytext); }
","         { printf("%-25s Separator\n", yytext); }
":"         { printf("%-25s Separator\n", yytext); }
"\""        { printf("%-25s Separator\n", yytext); }
"@"         { printf("%-25s Special\n", yytext); }

{INTCONST}  { validateIntConstant(yytext); }
{CHARCONST} { printf("%-25s Character constant\n", yytext); }
{STRINGCONST} { printf("%-25s String constant\n", yytext); }

{ID}        {
    if (!inVarDecl && !isDeclared(yytext)) {
        printf("%-25s Error: Variable used but not declared\n", yytext);
    } else {
        printf("%-25s Identifier\n", yytext);
    }
}

{PRINT_STMT} { validateIO(yytext, 0); }
{SCAN_STMT}  { validateIO(yytext, 1); }

.           { printf("%-25s Unknown token\n", yytext); }

%%

int main() {
    
    yyin=fopen( "input.txt", "r");
    yylex();
    return 0;
}