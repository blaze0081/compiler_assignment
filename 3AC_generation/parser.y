%{
#include "3AC.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "syntax.h"
extern FILE* yyin;
extern int yylineno;
extern int yylex(void);
void yyerror(const char *s);
int n = 1;
%}

/*
   Bison-based 3AC generator for the toy language
*/


%union {
    struct data data;
}

/* Token declarations */
%token <data> PROGRAM VARDECL 
%token <data> T_BEGIN END
%token <data> INT CHAR
%token <data> IF ELSE WHILE FOR DO TO
%token <data> INC DEC
%token <data> PRINT SCAN

%token <data> ASSIGN_EQUALS          /* := */
%token <data> PLUS_EQUALS            /* += */
%token <data> MINUS_EQUALS           /* -= */
%token <data> MULT_EQUALS            /* *= */
%token <data> DIV_EQUALS             /* /= */
%token <data> MODULO_EQUALS          /* %= */

%token <data> LESS_EQUALS            /* <= */
%token <data> GREATER_EQUALS         /* >= */
%token <data> NOT_EQUALS             /* <> */
%token <data> LESS                   /* < */
%token <data> GREATER                /* > */
%token <data> EQUALS                 /* := */

%token <data> PLUS                   /* + */
%token <data> MINUS                  /* - */
%token <data> MULT                   /* * */
%token <data> DIV                    /* / */
%token <data> MODULO                 /* % */

%token <data> LEFT_ROUND_PARAN       /* ( */
%token <data> RIGHT_ROUND_PARAN      /* ) */
%token <data> LEFT_SQ_PARAN          /* [ */
%token <data> RIGHT_SQ_PARAN         /* ] */

%token <data> SEMI_COLON             /* ; */
%token <data> COMMA                  /* , */
%token <data> COLON                  /* : */

%token <data> DIGIT
%token <data> INTEGER_CONSTANT
%token <data> CHAR_CONSTANT
%token <data> IO_STRING_CONSTANT
%token <data> IDENTIFIER

/* Nonterminal types */
%type <data> program variable_declaration declaration_list declaration variable_name type
%type <data> statement_list statement assignment_statement assignment_operators
%type <data> input_output_statement print_arguments print_formatted_text print_expression_list print_expression_item
%type <data> scan_arguments scan_formatted_text scan_variable_list scan_variable
%type <data> if_statement optional_else condition relop while_statement for_statement inc_dec
%type <data> expression arithmatic_operator factor variable block_statement

/* Operator precedence */
%left PLUS MINUS MULT DIV MODULO
%left LESS_EQUALS LESS GREATER GREATER_EQUALS
%left LEFT_ROUND_PARAN LEFT_SQ_PARAN RIGHT_ROUND_PARAN RIGHT_SQ_PARAN
%right ASSIGN_EQUALS PLUS_EQUALS MINUS_EQUALS MULT_EQUALS DIV_EQUALS MODULO_EQUALS NOT_EQUALS

/* In-grammar C declarations */
%code {
    #define MAX_ARGS 100
    char* printArgs[MAX_ARGS];
    int   printArgCount = 0;
    char* scanArgs[MAX_ARGS];
    int   scanArgCount  = 0;
}

%%

/* Program entry */
program:
    T_BEGIN PROGRAM COLON variable_declaration statement_list END PROGRAM
    {
      /* never pass NULL into printf */
      char *out = $5.code ? $5.code : "";
      printf("%s", out);
      YYACCEPT;
    }
;

/* Declarations */
variable_declaration:
    /* empty */ { $$.code = NULL; $$.str[0] = '\0'; }
  | T_BEGIN VARDECL COLON declaration_list END VARDECL
    { $$.code = NULL; $$.str[0] = '\0'; }
;

declaration_list:
    declaration_list declaration
  | declaration
;

declaration:
    LEFT_ROUND_PARAN variable_name COMMA type RIGHT_ROUND_PARAN SEMI_COLON
        { addSymbol($2.str, $4.str); }
  | LEFT_ROUND_PARAN variable_name LEFT_SQ_PARAN DIGIT RIGHT_SQ_PARAN COMMA type RIGHT_ROUND_PARAN SEMI_COLON
        { /* array decl if needed */ }
;

type:
    INT  { $$ = $1; strcpy($$.str, "int"); }
  | CHAR { $$ = $1; strcpy($$.str, "char"); }
;

variable_name:
    IDENTIFIER { $$ = $1; strcpy($$.str, $1.code); }
;

/* Statements */
statement_list:
  statement                   { $$ = $1; }
  | statement_list statement    { handle_rec_st(&$$, $1, $2); }
;

statement:
    assignment_statement SEMI_COLON     { $$ = $1; }
  | input_output_statement SEMI_COLON  { $$ = $1; }
  | if_statement SEMI_COLON            { $$ = $1; }
  | while_statement SEMI_COLON         { $$ = $1; }
  | for_statement SEMI_COLON           { $$ = $1; }
  | block_statement                    { $$ = $1; }
;

assignment_statement:
    variable assignment_operators expression
    { assignment_handle(&$$, $1, $2, $3, &n); }
;

assignment_operators:
    ASSIGN_EQUALS   { $$ = $1; strcpy($$.str, ":="); }
  | PLUS_EQUALS     { $$ = $1; strcpy($$.str, "+="); }
  | MINUS_EQUALS    { $$ = $1; strcpy($$.str, "-="); }
  | MULT_EQUALS     { $$ = $1; strcpy($$.str, "*="); }
  | DIV_EQUALS      { $$ = $1; strcpy($$.str, "/="); }
  | MODULO_EQUALS   { $$ = $1; strcpy($$.str, "%="); }
;

block_statement:
    T_BEGIN statement_list END
    { $$ = $2; }
;

input_output_statement:
    PRINT LEFT_ROUND_PARAN print_arguments RIGHT_ROUND_PARAN
        { validateIO($3.str, printArgs, printArgCount, 0); 
        $$ = $3; 
        printArgCount = 0;
        char *result=calloc(200,sizeof(char));
        sprintf(result,"print(%s)\n",$3.str);
        $$.code=result; 
        }
  | SCAN LEFT_ROUND_PARAN scan_arguments RIGHT_ROUND_PARAN
        { validateIO($3.str, scanArgs, scanArgCount, 1); 
        $$ = $3; 
        scanArgCount = 0; 
        char *result=calloc(200,sizeof(char));
        sprintf(result,"scan(%s)\n",$3.str);
        $$.code=result; 
        }
;

print_arguments:
    print_formatted_text
  | print_formatted_text COMMA print_expression_list
;

print_formatted_text:
    /* empty */                  { $$ .code = NULL; strcpy($$.str, ""); }
  | IO_STRING_CONSTANT         { $$ = $1; strcpy($$.str, $1.code); $$.code = NULL; }
;

print_expression_list:
    print_expression_item
  | print_expression_list COMMA print_expression_item  { handle_rec_st(&$$, $1, $3); }
;

print_expression_item:
    factor { printArgs[printArgCount++] = strdup($1.str); $$ = $1; }
;

scan_arguments:
    scan_formatted_text
  | scan_formatted_text COMMA scan_variable_list
;

scan_formatted_text:
    IO_STRING_CONSTANT { $$ = $1; strcpy($$.str, $1.code); $$.code = NULL; }
;

scan_variable_list:
    scan_variable
  | scan_variable_list COMMA scan_variable { /* chaining handled in validateIO */ }
;

scan_variable:
    IDENTIFIER { $$ = $1; scanArgs[scanArgCount++] = strdup($1.code); }
;

if_statement:
    IF condition block_statement optional_else
    {
        if ($4.code == NULL)
            conditional_if(&$$, $2, $3);
        else
            conditional_if_else(&$$, $2, $3, $4);
    }
  | IF LEFT_ROUND_PARAN condition RIGHT_ROUND_PARAN block_statement optional_else
  {
    if ($6.code == NULL)
      conditional_if(&$$, $3, $5);
    else
      conditional_if_else(&$$, $3, $5, $6);
  }

;


optional_else:
    /* empty */       
    { $$.code = NULL; $$.str[0] = '\0'; }
  | ELSE block_statement
    { $$ = $2; }
  ;


condition:
  variable relop expression
  {
    /* start with LHS */
    $$ = $1;
    /* build “x > (0,10)” */
    snprintf($$.str, sizeof($$.str), "%s %s %s",
             $1.str, $2.str, $3.str);

    /* prefix any temp‐code from $1 or $3 */
    int L = $1.code ? strlen($1.code) : 0;
    int R = $3.code ? strlen($3.code) : 0;
    if (L+R > 0) {
      char *c = calloc(L+R+1, 1);
      if ($1.code) memcpy(c,       $1.code, L);
      if ($3.code) memcpy(c + L,   $3.code, R);
      $$.code = c;
    } else {
      $$.code = NULL;
    }
  }
| variable
  {
    $$ = $1;
    $$.code = NULL;   /* bare var has no sub-code */
  }
;



relop:
    EQUALS        { strcpy($$.str, "="); }
  | NOT_EQUALS    { strcpy($$.str, "<>"); }
  | GREATER       { strcpy($$.str, ">"); }
  | LESS          { strcpy($$.str, "<"); }
  | GREATER_EQUALS{ strcpy($$.str, ">="); }
  | LESS_EQUALS   { strcpy($$.str, "<="); }
;

while_statement:
    WHILE LEFT_ROUND_PARAN condition RIGHT_ROUND_PARAN DO block_statement
        { while_handler(&$$, $3, $6); }
;

for_statement:
    FOR variable ASSIGN_EQUALS expression TO expression inc_dec expression DO block_statement
    {
        for_to(&$$, $2, $4, $6, $8, $7.str);
    }
    | FOR variable ASSIGN_EQUALS expression TO variable arithmatic_operator expression inc_dec expression DO block_statement
    {
        
    }
;


inc_dec:
    INC { strcpy($$.str, "inc"); }
  | DEC { strcpy($$.str, "dec"); }
;

expression:
    factor  { $$ = $1; }
  | expression arithmatic_operator factor
        { arithematic_comp(&$$, $1, $3, &n, $2.str); }
;

arithmatic_operator:
    PLUS    { strcpy($$.str, "+"); }
  | MINUS   { strcpy($$.str, "-"); }
  | MULT    { strcpy($$.str, "*"); }
  | DIV     { strcpy($$.str, "/"); }
  | MODULO  { strcpy($$.str, "%"); }
;

factor:
    variable                           { $$ = $1; }
  | INTEGER_CONSTANT
        { $$ = $1; strcpy($$.str, $1.code); $$.code = NULL; validateIntConstant($1.code); }
  | CHAR_CONSTANT
        { $$ = $1; strcpy($$.str, $1.code); $$.code = NULL; }
  | LEFT_ROUND_PARAN expression RIGHT_ROUND_PARAN { $$ = $2; }
;

variable:
    variable_name
    { 
      $$ = $1; 
      $$.code = NULL;
    }
  | variable_name LEFT_SQ_PARAN expression RIGHT_SQ_PARAN
        { array_handle(&$$, $1, $3, &n); }
;

%%

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input file>\n", argv[0]);
        return 1;
    }
    yyin = fopen(argv[1], "r");
    if (!yyin) { perror("Error opening file"); return 1; }
    yyparse();
    fclose(yyin);
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Syntax Error\n");
}
