%{
#include "y.tab.h"
%}

/* Regular Expression Definitions */
ID          [a-z]([a-z0-9]*_?[a-z0-9]*)?
INTCONST    \([0-9]+[ \t]*,[ \t]*[0-9]*\)
CHARCONST   \'(\\.|[^\\\'])?\'
STRINGCONST \"([^\"\\]|\\.)*\"
WS          [ \t\n]+
SLCOMMENT   "//".*\n
MLCOMMENT   "/*"([^*]|\*+[^*/])*\*+"/"


%%
{WS}        ;  /* Skip whitespace */
{SLCOMMENT} ;  /* Skip single-line comments */
{MLCOMMENT} ;  /* Skip multi-line comments */


"begin"     { return BEGIN; }
"end"       { return END; }
"int"       { return INT; }
"char"      { return CHAR; }
"if"        { return IF; }
"then"      { return THEN; }
"else"      { return ELSE; }
"while"     { return WHILE; }
"for"       { return FOR; }
"main"      { return MAIN; }
"program"   { return  PROGRAM;}
"VarDecl"   { return  VARDECL;}
"inc"       { return  INC;}
"dec"       { return  DEC;}
"print"     { return  PRINT;}
"scan"      { return  SCAN;}
"do"        { return  DO;}
"to"        { return  TO;}

":="        { return ASSIGN_EQUALS; }
"+="        { return PLUS_EQUALS; }
"-="        { return MINUS_EQUALS; }
"*="        { return MULT_EQUALS; }
"/="        { return DIV_EQUALS; }
"%="        { return MODULO_EUQALS; }
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
"{"         { return LEFT_CURLY_PARAN; }
"}"         { return RIGHT_CURLY_PARAN; }
";"         { return SEMI_COLON; }
","         { return COMMA; }
":"         { return COLON; }
"\ "        { return BACK_SLASH }
"@"         { return AT}
"\""        { return QUOTE}

{INTCONST}  { return INTEGER_CONSTANT; }
{CHARCONST} { return CHAR_CONSTANT; }
{STRINGCONST} { return STRING_CONSTANT; }
{ID}        { return IDENTIFIER; }

.           { /* UNKNOWN TOKEN */ }

%%

int yywrap() {
  return 1;
}