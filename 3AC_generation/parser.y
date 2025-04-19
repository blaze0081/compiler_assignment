%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "syntax.h"
extern FILE* yyin;
extern int yylineno;
extern int yylex(void);
extern int yydebug;
void yyerror(const char *s);
%}
%define api.value.type {char *}

/*tokens defined*/
/*
TOKENS NOT USED: MAIN, CURLY PARAN BACKSLASH, QUOTE, AT, THEN

*/
%union {
    struct data data;
}

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

/*FILL IN THESE LATER*/
%type <data> variable_declaration statement_list declaration_list declaration variable_name type
%type <data> assignment_statement input_output_statement if_statement while_statement for_statement block_statement
%type <data> variable assignment_operators expression print_arguments scan_arguments 
%type <data> print_formatted_text print_expression_list scan_formatted_text scan_variable_list
%type <data> optional_else condition relop inc_dec
%type <data> factor arithmatic_operator print_expression_item

%left PLUS MINUS MULT DIV MODULO
%left LESS_EQUALS LESS GREATER GREATER_EQUALS 
%left LEFT_ROUND_PARAN LEFT_SQ_PARAN RIGHT_ROUND_PARAN RIGHT_SQ_PARAN
%right ASSIGN_EQUALS PLUS_EQUALS MINUS_EQUALS MULT_EQUALS DIV_EQUALS MODULO_EQUALS NOT_EQUALS

%code {
    #define MAX_ARGS 100
    char* printArgs[MAX_ARGS];
    int printArgCount = 0;

    char* scanArgs[MAX_ARGS];
    int scanArgCount = 0;
}

%%



%%

/*CFG rules*/
program:
    T_BEGIN PROGRAM COLON variable_declaration statement_list END PROGRAM
    {
        printf("%s",$5.code);
        YYACCEPT;
    }
;

variable_declaration:
    /*empty*/
    | T_BEGIN VARDECL COLON declaration_list END VARDECL
;

declaration_list:
    declaration_list declaration
    | declaration
;

declaration:
    LEFT_ROUND_PARAN variable_name COMMA type RIGHT_ROUND_PARAN SEMI_COLON{ addSymbol($2, $4); }
    | LEFT_ROUND_PARAN variable_name LEFT_SQ_PARAN DIGIT RIGHT_SQ_PARAN COMMA type RIGHT_ROUND_PARAN SEMI_COLON
;


type:
    INT
    | CHAR
;

variable_name:
    IDENTIFIER
;

statement_list:
    /*empty*/
    | statement {$$.code=$1.code;}
    | statement_list statement { handle_rec_st(&$$,$1,$2);}
;

statement:
    assignment_statement SEMI_COLON {$$.code=$1.code;}
    | input_output_statement SEMI_COLON {$$.code=$1.code;}
    | if_statement SEMI_COLON {$$.code=$1.code;}
    | while_statement SEMI_COLON {$$.code=$1.code;}
    | for_statement SEMI_COLON {$$.code=$1.code;}
    | block_statement {$$.code=$1.code;}
;

assignment_statement:
    variable assignment_operators expression
;

assignment_operators:
    ASSIGN_EQUALS 
    | PLUS_EQUALS 
    | MINUS_EQUALS 
    | MULT_EQUALS 
    | DIV_EQUALS 
    | MODULO_EQUALS
;

block_statement:
    T_BEGIN statement_list END
;

input_output_statement:
    PRINT LEFT_ROUND_PARAN print_arguments RIGHT_ROUND_PARAN {
        validateIO($3, printArgs, printArgCount, 0);
        printArgCount = 0;  // reset for next use
    }
    | SCAN LEFT_ROUND_PARAN scan_arguments RIGHT_ROUND_PARAN {
        validateIO($3, scanArgs, scanArgCount, 1);
        scanArgCount = 0;  // reset for next use
    }
;


print_arguments:
    print_formatted_text
    | print_formatted_text COMMA print_expression_list 
;

print_formatted_text:
    /*empty* print()*/ 
    | IO_STRING_CONSTANT
;


print_expression_list:
    print_expression_item 
    | print_expression_list COMMA print_expression_item 
;

print_expression_item:
    factor {printArgs[printArgCount++] = $1; $$ = $1;}
;


scan_arguments:
    scan_formatted_text
    | scan_formatted_text COMMA scan_variable_list
;

scan_formatted_text:
    IO_STRING_CONSTANT
;

scan_variable_list:
    scan_variable
    | scan_variable_list COMMA scan_variable
;

scan_variable:
    IDENTIFIER { scanArgs[scanArgCount++] = $1; $$ = $1; }
;


if_statement:
    IF condition block_statement optional_else
    | IF LEFT_ROUND_PARAN condition RIGHT_ROUND_PARAN block_statement optional_else
;

optional_else:
    /*empty*/
    | ELSE block_statement
;

condition:
    variable relop expression
    | variable
;

relop:
    EQUALS
    | NOT_EQUALS
    | GREATER
    | LESS
    | GREATER_EQUALS
    | LESS_EQUALS
;

while_statement:
    WHILE LEFT_ROUND_PARAN condition RIGHT_ROUND_PARAN DO block_statement
;

for_statement:
    FOR variable ASSIGN_EQUALS expression TO expression inc_dec expression DO block_statement
    | FOR variable ASSIGN_EQUALS expression TO variable arithmatic_operator expression inc_dec expression DO block_statement
;

inc_dec: 
    INC
    | DEC
;

expression:
    factor
    | factor arithmatic_operator factor
;

arithmatic_operator:
    PLUS
    | MINUS
    | MULT
    | DIV
    | MODULO
;

factor:
    variable
    | INTEGER_CONSTANT{
        validateIntConstant($1);
    }
    | CHAR_CONSTANT
    | LEFT_ROUND_PARAN expression RIGHT_ROUND_PARAN
;


variable:
    variable_name
    | variable_name LEFT_SQ_PARAN expression RIGHT_SQ_PARAN
;

%%

int main(int argc, char *argv[]) {
    /*CHECK FOR DEBUGGING REMOVE LATER*/
    /* yydebug = 1; */

    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input file>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Error opening file");
        return 1;
    }

    yyparse();
    fclose(yyin);
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Syntax Error\n");
}
