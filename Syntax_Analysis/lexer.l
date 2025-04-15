%{
#include "y.tab.h"
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

{DIGITS}    { yylval = strdup(yytext); return DIGIT; }
{INTCONST}  { yylval = strdup(yytext); return INTEGER_CONSTANT; }
{CHARCONST} { yylval = strdup(yytext); return CHAR_CONSTANT; }
{IO_STRINGCONST} { yylval = strdup(yytext); return IO_STRING_CONSTANT; }


{ID}        { yylval = strdup(yytext); return IDENTIFIER; }

.           { /* UNKNOWN TOKEN */ }

%%

int yywrap() {
  return 1;
}