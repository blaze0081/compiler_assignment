%{
#include "parser.tab.h"
#include <string.h>
#include <limits.h>
#include <ctype.h>

int convert_to_decimal(int value, int base) {
    if (base < 2 || base > 10) {
        printf("Invalid base.  Must be 2, 8, or 10.\n");
        return -1; // Return -1 to indicate an error
    }

    if (value < 0) {
        printf("Invalid input value (negative number).\n");
        return -1;
    }

    int result = 0;
    int multiplier = 1;

    while (value > 0) {
        int digit = value % 10;
        if (digit >= base) {
            printf("Digit %d is invalid for base %d.\n", digit, base);
            return -1;
        }
        if (result > INT_MAX - (digit * multiplier))
        {
             printf("Overflow error.\n");
            return -1;
        }
        result += digit * multiplier;
        multiplier *= base;
        value /= 10;
    }
    return result;
}

int validateIntConstant(const char *text) {
    int len = strlen(text);
    if (len < 5) {
        printf("Syntax Error\n");
        exit(1);
    }
    
    char inner[256];
    strncpy(inner, text+1, len-2);
    inner[len-2] = '\0';
    
    char *comma = strchr(inner, ',');
    if (!comma) {
        printf("Syntax Error\n");
        exit(1);
    }
    
    *comma = '\0';
    char *value = inner;
    char *base = comma + 1;
    
    while(isspace(*value)) value++;
    while(isspace(*base)) base++;
    char *endPtr = base + strlen(base) - 1;
    while(endPtr > base && isspace(*endPtr)) { *endPtr = '\0'; endPtr--; }
    
    if (strlen(value) == 0 || strlen(base) == 0) {
        printf("Syntax Error\n");
        exit(1);
    }
    
    int baseNum = atoi(base);
    if (baseNum != 2 && baseNum != 8 && baseNum != 10) {
        printf("Syntax Error\n");
        exit(1);
    }
    
    for (int i = 0; value[i] != '\0'; i++) {
        if (!isdigit(value[i])) {
            printf("Syntax Error\n");
            exit(1);
        }
        int digit = value[i] - '0';
        if (baseNum == 8 && digit > 7) {
            printf("Syntax Error\n");
            exit(1);
        }
        if (baseNum == 2 && digit > 1) {
            printf("Syntax Error\n");
            exit(1);
        }
    }
    int result = convert_to_decimal(atoi(value), baseNum);
    // printf("%d\n", result);
    return result;
}


%}

/* Regular Expression Definitions */
SLCOMMENT                 "//".*\n
MLCOMMENT                 "/*"([^*]|\*+[^*/])*\*+"/"
DIGITS                    [0-9]+
ID                        [a-z]([a-z0-9]*_?[a-z0-9]*)?
INTCONST                  \([0-9]+[ \t]*,[ \t]*[0-9]*\)
CHARCONST                 \'(\\.|[^\\\'])?\'
IO_STRINGCONST            \"[^\"]*\"
WS                        [ \t\n]+



%%
{WS}        ;  /* Skip whitespace */
{SLCOMMENT} ;  /* Skip single-line comments */
{MLCOMMENT} ;  /* Skip multi-line comments */


"begin"     { return T_BEGIN; }
"end"       { return END; }
"int"       { return INT; }
"char"      { return CHAR; }
"if"        { return IF; }
"else"      { return ELSE; }
"while"     { return WHILE; }
"for"       { return FOR; }
"program"   { return PROGRAM;}
"VarDecl"   { return VARDECL;}
"inc"       { return INC;}
"dec"       { return DEC;}
"print"     { return PRINT;}
"scan"      { return SCAN;}
"do"        { return DO;}
"to"        { return TO;}

":="        { return ASSIGN_EQUALS; }
"+="        { return PLUS_EQUALS; }
"-="        { return MINUS_EQUALS; }
"*="        { return MULT_EQUALS; }
"/="        { return DIV_EQUALS; }
"%="        { return MODULO_EQUALS; }
"<="        { return LESS_EQUALS;}
">="        { return GREATER_EQUALS; }
"<>"        { return NOT_EQUALS; }
"<"         { return LESS; }
">"         { return GREATER; }
"="         { return EQUALS; }

"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return MULT; }
"/"         { return DIV; }
"%"         { return MODULO; }

"("         { return LEFT_ROUND_PARAN; }
")"         { return RIGHT_ROUND_PARAN; }
"["         { return LEFT_SQ_PARAN; }
"]"         { return RIGHT_SQ_PARAN; }
";"         { return SEMI_COLON; }
","         { return COMMA; }
":"         { return COLON; }

{DIGITS}    { yylval.data.type=0; yylval.data.ival=atoi(yytext); return DIGIT; }
{INTCONST}  { yylval.data.ival = validateIntConstant(yytext); return INTEGER_CONSTANT; }
{CHARCONST} { yylval.data.type=1; strcpy(yylval.data.str,yytext); return CHAR_CONSTANT; }
{IO_STRINGCONST} { strcpy(yylval.data.str,yytext); return IO_STRING_CONSTANT; }


{ID}        { strcpy(yylval.data.str,yytext); return IDENTIFIER; }

.           { /* UNKNOWN TOKEN */ }

%%

int yywrap() {
  return 1;
}