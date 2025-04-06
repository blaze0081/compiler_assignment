%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern FILE* yyin;
extern int yylineno;
extern int yylex(void);
extern int yydebug;
void yyerror(const char *s);

%}

/*tokens defined*/
/*
TOKENS NOT USED: MAIN, CURLY PARAN BACKSLASH, QUOTE, AT, THEN


*/
%token PROGRAM VARDECL 
%token T_BEGIN END
%token INT CHAR
%token IF ELSE WHILE FOR DO TO
%token INC DEC
%token PRINT SCAN

%token ASSIGN_EQUALS          /* := */
%token PLUS_EQUALS            /* += */
%token MINUS_EQUALS           /* -= */
%token MULT_EQUALS            /* *= */
%token DIV_EQUALS             /* /= */
%token MODULO_EQUALS          /* %= */

%token LESS_EQUALS            /* <= */
%token GREATER_EQUALS         /* >= */
%token NOT_EQUALS             /* <> */
%token LESS                   /* < */
%token GREATER                /* > */
%token EQUALS                 /* := */

%token PLUS                   /* + */
%token MINUS                  /* - */
%token MULT                   /* * */
%token DIV                    /* / */
%token MODULO                 /* % */

%token LEFT_ROUND_PARAN       /* ( */
%token RIGHT_ROUND_PARAN      /* ) */
%token LEFT_SQ_PARAN          /* [ */
%token RIGHT_SQ_PARAN         /* ] */

%token SEMI_COLON             /* ; */
%token COMMA                  /* , */
%token COLON                  /* : */

%token DIGIT
%token INTEGER_CONSTANT
%token CHAR_CONSTANT
%token PRINT_STRING_CONSTANT
%token SCAN_STRING_CONSTANT
%token IDENTIFIER

/*FILL IN THESE LATER*/
%type variable_declaration statement_list declaration_list declaration variable_name type
%type assignment_statement input_output_statement if_statement while_statement for_statement block_statement
%type variable assignment_operators expression print_arguments scan_arguments 
%type print_formatted_text print_expression_list scan_formatted_text scan_variable_list
%type optional_else condition relop inc_dec
%type factor arithmatic_operator 

%left PLUS MINUS MULT DIV MODULO
%left LESS_EQUALS LESS GREATER GREATER_EQUALS 
%left LEFT_ROUND_PARAN LEFT_SQ_PARAN RIGHT_ROUND_PARAN RIGHT_SQ_PARAN
%right ASSIGN_EQUALS PLUS_EQUALS MINUS_EQUALS MULT_EQUALS DIV_EQUALS MODULO_EQUALS NOT_EQUALS




%%

/*CFG rules*/
program:
    T_BEGIN PROGRAM COLON variable_declaration statement_list END PROGRAM
    {
        printf("Valid Program\n");
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
    LEFT_ROUND_PARAN variable_name COMMA type RIGHT_ROUND_PARAN SEMI_COLON
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
    | statement
    | statement_list statement
;

statement:
    assignment_statement SEMI_COLON
    | input_output_statement SEMI_COLON
    | if_statement SEMI_COLON
    | while_statement SEMI_COLON
    | for_statement SEMI_COLON
    | block_statement
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
    PRINT LEFT_ROUND_PARAN print_arguments RIGHT_ROUND_PARAN
    | SCAN LEFT_ROUND_PARAN scan_arguments RIGHT_ROUND_PARAN
;

print_arguments:
    print_formatted_text
    | print_formatted_text COMMA print_expression_list
;

print_formatted_text:
    /*empty* print()*/ 
    | PRINT_STRING_CONSTANT
;


print_expression_list:
    IDENTIFIER
    | print_expression_list COMMA IDENTIFIER
;


scan_arguments:
    scan_formatted_text
    | scan_formatted_text COMMA scan_variable_list
;

scan_formatted_text:
    SCAN_STRING_CONSTANT
;

scan_variable_list:
    IDENTIFIER
    | scan_variable_list COMMA IDENTIFIER
;

if_statement:
    IF condition block_statement optional_else
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
    WHILE LEFT_ROUND_PARAN condition RIGHT_ROUND_PARAN block_statement
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
    | INTEGER_CONSTANT
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
    fprintf(stderr, "Syntax Error: %s at line %d\n", s, yylineno);
}
