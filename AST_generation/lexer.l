%{
#include "parser.tab.h"
#include "ast.h"

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


"begin"     { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return T_BEGIN; }
"end"       { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return END; }
"int"       { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return INT; }
"char"      { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return CHAR; }
"if"        { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return IF; }
"else"      { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return ELSE; }
"while"     { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return WHILE; }
"for"       { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return FOR; }
"program"   { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return PROGRAM;}
"VarDecl"   { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return VARDECL;}
"inc"       { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return INC;}
"dec"       { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return DEC;}
"print"     { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return PRINT;}
"scan"      { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return SCAN;}
"do"        { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return DO;}
"to"        { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return TO;}

":="        { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return ASSIGN_EQUALS; }
"+="        { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return PLUS_EQUALS; }
"-="        { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return MINUS_EQUALS; }
"*="        { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return MULT_EQUALS; }
"/="        { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return DIV_EQUALS; }
"%="        { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return MODULO_EQUALS; }
"<="        { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return LESS_EQUALS;}
">="        { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return GREATER_EQUALS; }
"<>"        { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return NOT_EQUALS; }
"<"         { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return LESS; }
">"         { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return GREATER; }
"="         { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return EQUALS; }

"+"         { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return PLUS; }
"-"         { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return MINUS; }
"*"         { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return MULT; }
"/"         { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return DIV; }
"%"         { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return MODULO; }

"("         { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return LEFT_ROUND_PARAN; }
")"         { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return RIGHT_ROUND_PARAN; }
"["         { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return LEFT_SQ_PARAN; }
"]"         { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return RIGHT_SQ_PARAN; }
";"         { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return SEMI_COLON; }
","         { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return COMMA; }
":"         { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return COLON; }

{DIGITS}    { yylval.tree=createNode();Node*t=createNode();  yylval.tree->ival=atoi(yytext); strcpy(yylval.tree->name,"DIGIT"); strcpy(t->name,yytext); addchild(yylval.tree,t); return DIGIT; }
{INTCONST}  { yylval.tree=createNode();Node*t=createNode();  yylval.tree->ival=atoi(yytext); strcpy(yylval.tree->name,"INTCONST"); strcpy(t->name,yytext); addchild(yylval.tree,t); return INTEGER_CONSTANT; }
{CHARCONST} { yylval.tree=createNode();Node*t=createNode();  strcpy(yylval.tree->name,"CHARCONST"); strcpy(t->name,yytext); addchild(yylval.tree,t); return CHAR_CONSTANT; }
{IO_STRINGCONST} { yylval.tree=createNode();Node*t=createNode(); strcpy(yylval.tree->name,"IOCONST"); strcpy(t->name,yytext); addchild(yylval.tree,t); return IO_STRING_CONSTANT; }


{ID}        { yylval.tree=createNode(); strcpy(yylval.tree->name,yytext); return IDENTIFIER; }

.           { /* UNKNOWN TOKEN */ }

%%

int yywrap() {
  return 1;
}