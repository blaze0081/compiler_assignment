%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "syntax.h"
extern FILE* yyin;
extern int yylineno;
extern int yylex(void);
void yyerror(const char *s);
%}
%code requires {
    #include "ast.h"
}

%union {
    Node* tree;
}
/*tokens defined*/
/*
TOKENS NOT USED: MAIN, CURLY PARAN BACKSLASH, QUOTE, AT, THEN

*/
%token <tree> PROGRAM VARDECL 
%token <tree> T_BEGIN END
%token <tree> INT CHAR
%token <tree> IF ELSE WHILE FOR DO TO
%token <tree> INC DEC
%token <tree> PRINT SCAN
 
%token <tree> ASSIGN_EQUALS          /* := */
%token <tree> PLUS_EQUALS            /* += */
%token <tree> MINUS_EQUALS           /* -= */
%token <tree> MULT_EQUALS            /* *= */
%token <tree> DIV_EQUALS             /* /= */
%token <tree> MODULO_EQUALS          /* %= */
 
%token <tree> LESS_EQUALS            /* <= */
%token <tree> GREATER_EQUALS         /* >= */
%token <tree> NOT_EQUALS             /* <> */
%token <tree> LESS                   /* < */
%token <tree> GREATER                /* > */
%token <tree> EQUALS                 /* := */
 
%token <tree> PLUS                   /* + */
%token <tree> MINUS                  /* - */
%token <tree> MULT                   /* * */
%token <tree> DIV                    /* / */
%token <tree> MODULO                 /* % */
 
%token <tree> LEFT_ROUND_PARAN       /* ( */
%token <tree> RIGHT_ROUND_PARAN      /* ) */
%token <tree> LEFT_SQ_PARAN          /* [ */
%token <tree> RIGHT_SQ_PARAN         /* ] */
 
%token <tree> SEMI_COLON             /* ; */
%token <tree> COMMA                  /* , */
%token <tree> COLON                  /* : */
 
%token <tree> DIGIT
%token <tree> INTEGER_CONSTANT
%token <tree> CHAR_CONSTANT
%token <tree> IO_STRING_CONSTANT
%token <tree> IDENTIFIER

/*FILL IN THESE LATER*/
%type <tree> program variable_declaration statement_list declaration_list declaration variable_name type
%type <tree> assignment_statement input_output_statement if_statement while_statement for_statement block_statement
%type <tree> variable assignment_operators expression print_arguments scan_arguments 
%type <tree> print_formatted_text print_expression_list scan_formatted_text scan_variable_list
%type <tree> condition relop inc_dec expression_check print_expression_item
%type <tree> factor arithmatic_operator statement variable_aop_exp

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


/*CFG rules*/
program:
    T_BEGIN PROGRAM COLON variable_declaration statement_list END PROGRAM
    {
        $$=createNode();
        strcpy($$->name,"PROGRAM");
        addchild($$,$4);
        addchild($$,$5);
        myhead=$$;
        dfs(myhead);
        printf("Valid Program\n");
        YYACCEPT;
    }
;

variable_declaration:
    T_BEGIN VARDECL COLON declaration_list END VARDECL
    {
        $$=$4;
    }
;

declaration_list:
    declaration
    {
        $$=createNode();
        setname($$,"Variable_Declaration");
        addchild($$,$1);
    }
    | declaration_list declaration
    {
        addchild($1,$2);
        $$=$1;
    }
;

declaration:
    LEFT_ROUND_PARAN variable_name COMMA type RIGHT_ROUND_PARAN SEMI_COLON
    {
        setname($2,$4->name);
        $$=$2;
    }
    | LEFT_ROUND_PARAN variable_name LEFT_SQ_PARAN DIGIT RIGHT_SQ_PARAN COMMA type RIGHT_ROUND_PARAN SEMI_COLON
    {
        $$ = createNode();
        setname($$, "Array_Declaration");
        addchild($$, $2);
        addchild($$, $4);
        addchild($$, $7);
    }
;

type:
    INT {$$=$1;}
    | CHAR {$$=$1;}
;

variable_name:
    IDENTIFIER
    {
        $$=createNode();
        addchild($$,$1);
    } 
;

statement_list:
    statement 
    {
        $$=createNode();
        setname($$,"STATEMENTS");
        addchild($$,$1);
    }
    | statement_list statement 
    {
        addchild($1,$2);
        $$=$1;
    }
;

statement:
    assignment_statement SEMI_COLON
    {
        $$=$1;
    }
    | input_output_statement SEMI_COLON
    {
        $$=$1;
    }
    | if_statement SEMI_COLON
    {
        $$=$1;
    }
    | while_statement SEMI_COLON
    {
        $$=$1;
    }
    | for_statement SEMI_COLON
    {
        $$=$1;
    }
    | block_statement
    {
        $$=$1;
    }
;

assignment_statement:
    variable assignment_operators expression
    {
        $$=createNode();
        setname($$,$2->name);
        addchild($$,$1);
        addchild($$,$3);
    }
;

assignment_operators:
    ASSIGN_EQUALS
    {
        $$=$1;
    }
    | PLUS_EQUALS
    {
        $$=$1;
    }
    | MINUS_EQUALS
    {
        $$=$1;
    }
    | MULT_EQUALS
    {
        $$=$1;
    }
    | DIV_EQUALS
    {
        $$=$1;
    }
    | MODULO_EQUALS
    {
        $$=$1;
    }
;

block_statement:
    T_BEGIN statement_list END
    {
        $$ = createNode();
        setname($$, "Block");
        addchild($$, $2);
    }
;

input_output_statement:
    PRINT LEFT_ROUND_PARAN print_arguments RIGHT_ROUND_PARAN 
    {
        validateIO($3, printArgs, printArgCount, 0);
        printArgCount = 0;  
        $$=$3;
    }
    | SCAN LEFT_ROUND_PARAN scan_arguments RIGHT_ROUND_PARAN
    {
        validateIO($3, scanArgs, scanArgCount, 1);
        scanArgCount = 0;  
        $$=$3;
    }
;

print_arguments:
    print_formatted_text
    {
        $$ = createNode();
        setname($$, "Print");
        addchild($$, $1);
    }
    | print_formatted_text COMMA print_expression_list
    {
        $$ = createNode();
        setname($$, "Print");
        addchild($$, $1);  
        addchild($$, $3);  
    }
;

print_formatted_text:
    IO_STRING_CONSTANT
    {
        $$=$1;
    }
;

print_expression_list:
    print_expression_item
    {
        $$=$1;
    }
    | print_expression_list COMMA print_expression_item 
    {
        addchild($$, $3);
        $$=$1;
    }
;

print_expression_item:
    factor 
    {
        printArgs[printArgCount++] = $1; 
        $$ = $1;
    }
;


scan_arguments:
    scan_formatted_text COMMA scan_variable_list
    {
        $$ = createNode();
        setname($$, "Scan");
        addchild($$, $1);
        addchild($$, $3);
    }
;

scan_formatted_text:
    IO_STRING_CONSTANT
    {
        $$=$1;
    }
;

scan_variable_list:
    IDENTIFIER
    {
        $$ = createNode();
        setname($$, "IDENTIFIER");
        addchild($$, $1);
    }
    | scan_variable_list COMMA IDENTIFIER
    {
        $$ = $1;
        addchild($$, $3);
    }
;

if_statement:
    IF condition block_statement
    {
        $$=createNode();
        setname($$,"Branch");
        addchild($$,$2);
        addchild($$,$3);
        
    }
    | IF condition block_statement ELSE block_statement
    {
        $$=createNode();
        setname($$,"Branch");
        addchild($$,$2);
        addchild($$,$3);
        addchild($$,$5);
        
    }
    | IF LEFT_ROUND_PARAN condition RIGHT_ROUND_PARAN block_statement
    {
        $$=createNode();
        setname($$,"Branch");
        addchild($$,$3);
        addchild($$,$5);
        
    }
    | IF LEFT_ROUND_PARAN condition RIGHT_ROUND_PARAN block_statement ELSE block_statement
    {
        $$=createNode();
        setname($$,"Branch");
        addchild($$,$3);
        addchild($$,$5);
        addchild($$,$7);
        
    }
;


condition:
    variable relop expression
    {
        $$=createNode();
        setname($$,$2->name);
        addchild($$,$1);
        addchild($$,$3);
        
    }
    | variable
    {
        $$=createNode();
        setname($$,$1->name);
        addchild($$,$1);
        
    }
;

relop:
    EQUALS
    {
        $$=$1;
    }
    | NOT_EQUALS
    {
        $$=$1;
    }
    | GREATER
    {
        $$=$1;
    }
    | LESS
    {
        $$=$1;
    }
    | GREATER_EQUALS
    {
        $$=$1;
    }
    | LESS_EQUALS
    {
        $$=$1;
    }
;

while_statement:
    WHILE LEFT_ROUND_PARAN condition RIGHT_ROUND_PARAN block_statement
    {
         $$=createNode();
        setname($$,"WHILE");
        addchild($$,$3);
        addchild($$,$5);
    }
;

for_statement:
    FOR variable ASSIGN_EQUALS expression TO expression_check DO block_statement
    {
        $$=createNode();
        setname($$,"FOR");
        addchild($$,$2);
        addchild($$,$4);
        addchild($$,$6);
        addchild($$,$8);
    }
    | FOR variable ASSIGN_EQUALS expression TO variable_aop_exp DO block_statement
    {
        $$=createNode();
        setname($$,"FOR");
        addchild($$,$2);
        addchild($$,$4);
        addchild($$,$6);
        addchild($$,$8);
    }
;

variable_aop_exp: 
    variable arithmatic_operator expression_check
    {
        $$=createNode();
        setname($$,$2->name);
        addchild($$,$1);
        addchild($$,$3);
    }
;

expression_check: 
    expression inc_dec expression
    {
        $$=createNode();
        setname($$,$2->name);
        addchild($$,$1);
        addchild($$,$3);
    }
;


inc_dec: 
    INC
    {
        $$=$1;
    }
    | DEC
    {
        $$=$1;
    }
;

expression:
    factor
    {
        $$=$1;
    }
    | factor arithmatic_operator factor
    {
        $$=createNode();
        setname($$,$2->name);
        addchild($$,$1);
        addchild($$,$3);
    }
;

arithmatic_operator:
    PLUS
    {
        $$=$1;
    }
    | MINUS
    {
        $$=$1;
    }
    | MULT
    {
        $$=$1;
    }
    | DIV
    {
        $$=$1;
    }
    | MODULO
    {
        $$=$1;
    }
;

factor:
    variable
    {
        $$=$1;
    }
    | INTEGER_CONSTANT
    {
        /*validateIntConstant($1); [THIS PART IS NOT WORKING FIX THIS]*/ 
        $$=$1;
    }
    | CHAR_CONSTANT
    {
        $$=$1;
    }
    | LEFT_ROUND_PARAN expression RIGHT_ROUND_PARAN
    {
        $$=$2;
    }
;


variable:
    variable_name
    {
        $$=$1;
    }
    | variable_name LEFT_SQ_PARAN expression RIGHT_SQ_PARAN
    /*COMPLETE THIS PART*/
;

%%

int main(int argc, char *argv[]) {

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
