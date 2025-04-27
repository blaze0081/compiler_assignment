%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol.h"
extern FILE* yyin;
extern int yylineno;
extern int yylex(void);
extern int yydebug;
void yyerror(const char *s);

table *symboltable; 

/* ————————————————————————————————
   execution‐control stack for if/else
   ———————————————————————————————— */
static bool execFlag[100];
static int  execTop   = -1;
static bool lastIfCond;         /* remember the just‐tested condition */

static bool curExec() { 
  /* if nothing on stack, default to “true” */
  return execTop < 0 || execFlag[execTop]; 
}
static void pushExec(bool v) {
  execFlag[++execTop] = v;
}
static void popExec() {
  if (execTop >= 0) execTop--;
}

%}

%union {
    int    type;      
    int    ival;      
    int    value; 
    char   str[100];  
    int    op;
}

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

%token <op> ASSIGN_EQUALS          /* := */
%token <op> PLUS_EQUALS            /* += */
%token <op> MINUS_EQUALS           /* -= */
%token <op> MULT_EQUALS            /* *= */
%token <op> DIV_EQUALS             /* /= */
%token <op> MODULO_EQUALS          /* %= */

%token <op> LESS_EQUALS      /* <= */
%token <op> GREATER_EQUALS   /* >= */
%token <op> NOT_EQUALS       /* <> */
%token <op> LESS             /* <  */
%token <op> GREATER          /* >  */
%token <op> EQUALS           /* =  */

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

%token <ival> DIGIT
%token <ival> INTEGER_CONSTANT
%token <str> CHAR_CONSTANT
%token <str> IO_STRING_CONSTANT
%token <str> IDENTIFIER

/*FILL IN THESE LATER*/
%type variable_declaration statement_list declaration_list declaration 
%type assignment_statement input_output_statement if_statement while_statement for_statement block_statement
%type print_arguments scan_arguments 
%type print_formatted_text print_expression_list scan_formatted_text scan_variable_list
%type optional_else inc_dec scan_variable
%type print_expression_item

%type  <op>  arithmetic_operator assignment_operators relop
%type <type> type 
%type <ival> expression factor variable condition

%left PLUS MINUS MULT DIV MODULO
%left LESS_EQUALS LESS GREATER GREATER_EQUALS 
%left LEFT_ROUND_PARAN LEFT_SQ_PARAN RIGHT_ROUND_PARAN RIGHT_SQ_PARAN
%right ASSIGN_EQUALS PLUS_EQUALS MINUS_EQUALS MULT_EQUALS DIV_EQUALS MODULO_EQUALS NOT_EQUALS




%%

/*CFG rules*/
program:
    T_BEGIN PROGRAM COLON variable_declaration statement_list END PROGRAM
    {
    printf("Program executed successfully.\n\nSymbol Table:\n");
    for(int i=0; i<symboltable->numEntries; i++){
      entry *e = symboltable->entries[i];
      printf("  %-10s : %-7s  init=%-3s  value=%d\n",
          e->id,
          (e->type==TY_INT ? "int" : e->type==TY_CHAR ? "char" : "??"),
          (e->isSet? "yes":"no"),
          e->value);
    }
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
    LEFT_ROUND_PARAN IDENTIFIER COMMA type RIGHT_ROUND_PARAN SEMI_COLON
    {
        /* insert into symbol table, error on duplicate */
        if (!insertEntry(symboltable, $2, $4))
            printf("Error: Multiple declaration of variable '%s'\n", $2);
    }
    | LEFT_ROUND_PARAN IDENTIFIER LEFT_SQ_PARAN DIGIT RIGHT_SQ_PARAN COMMA type RIGHT_ROUND_PARAN SEMI_COLON
    /*ADD ARRAY SUPPORT*/
;


type:
      INT  { $$ = TY_INT; }
    | CHAR { $$ = TY_CHAR; }
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
    IDENTIFIER assignment_operators expression
    {
        if (curExec()) {
            if (!searchEntry(symboltable, $1)) {
                printf("Error: Undeclared variable '%s'\n", $1);
            } else {
                setEntry(symboltable, $1);
                setEntryValue(symboltable, $1, $3, $2);
                int destT = getEntryType(symboltable, $1);
            }
        }
    }
;

assignment_operators:
    ASSIGN_EQUALS     { $$ = ASSIGN_EQUALS; }
  | PLUS_EQUALS       { $$ = PLUS_EQUALS;   }
  | MINUS_EQUALS      { $$ = MINUS_EQUALS;  }
  | MULT_EQUALS       { $$ = MULT_EQUALS;   }
  | DIV_EQUALS        { $$ = DIV_EQUALS;    }
  | MODULO_EQUALS     { $$ = MODULO_EQUALS; }
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
    | IO_STRING_CONSTANT
;


print_expression_list:
    print_expression_item 
    | print_expression_list COMMA print_expression_item 
;

print_expression_item:
    factor 
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
    IDENTIFIER 
;


if_statement:
    IF condition
      {
        lastIfCond = curExec() && $2;   /* here the condition is $2 */
        pushExec(lastIfCond);
      }
    block_statement
      { popExec(); }
    optional_else
    | IF LEFT_ROUND_PARAN condition RIGHT_ROUND_PARAN
     {
       lastIfCond = curExec() && $3;   /* use $3 for the condition */
       pushExec(lastIfCond);
     }
    block_statement
      { popExec(); }
    optional_else
  ;

optional_else:
    /* no else: do nothing */
  | ELSE
      { 
        /* now should we run the ELSE‐block? */
        pushExec(curExec() && !lastIfCond);
      }
    block_statement
      { popExec(); }
  ;

condition:
    variable relop expression
    {
      switch ($2) {
        case EQUALS:        $$ = ($1 == $3); break;
        case NOT_EQUALS:    $$ = ($1 != $3); break;
        case LESS:          $$ = ($1 <  $3); break;
        case GREATER:       $$ = ($1 >  $3); break;
        case LESS_EQUALS:   $$ = ($1 <= $3); break;
        case GREATER_EQUALS:$$ = ($1 >= $3); break;
      }
    }
  | variable
    {
      /* non-zero var → true */
      $$ = ($1 != 0);
    }
  ;

relop:
    LESS_EQUALS    { $$ = LESS_EQUALS; }
  | GREATER_EQUALS { $$ = GREATER_EQUALS; }
  | NOT_EQUALS     { $$ = NOT_EQUALS; }
  | LESS           { $$ = LESS; }
  | GREATER        { $$ = GREATER; }
  | EQUALS         { $$ = EQUALS; }
  ;

while_statement:
    WHILE LEFT_ROUND_PARAN condition RIGHT_ROUND_PARAN DO block_statement
;

for_statement:
    FOR variable ASSIGN_EQUALS expression TO expression inc_dec expression DO block_statement
    | FOR variable ASSIGN_EQUALS expression TO variable arithmetic_operator expression inc_dec expression DO block_statement
;

inc_dec: 
    INC
    | DEC
;

expression:
    factor
    | factor arithmetic_operator factor
    {
        switch ($2) {
          case '+': $$ = $1 + $3; break;
          case '-': $$ = $1 - $3; break;
          case '*': $$ = $1 * $3; break;
          case '/':
            if ($3 == 0) yyerror("divide by zero");
            else         $$ = $1 / $3;
            break;
          case '%':
            if ($3 == 0) yyerror("modulo by zero");
            else         $$ = $1 % $3;
            break;
        }
      }
;

arithmetic_operator
  : PLUS   { $$ = '+'; }
  | MINUS  { $$ = '-'; }
  | MULT   { $$ = '*'; }
  | DIV { $$ = '/'; }
  | MODULO { $$ = '%'; }
  ;

factor:
    variable
    | INTEGER_CONSTANT
    {
      /* yylval.ival was set by your lexer, so just pass it through */
      $$ = $1;
    }
    | CHAR_CONSTANT
    | LEFT_ROUND_PARAN expression RIGHT_ROUND_PARAN
;


variable:
    IDENTIFIER
    {
      if (!searchEntry(symboltable,$1)) {
        printf("Error: Undeclared '%s'\n",$1);
        $$ = 0;
      } else {
        checkSet(symboltable,$1);
        /* look up the stored value: */
        $$ = getEntryValue(symboltable,$1);
      }
    }
    | IDENTIFIER LEFT_SQ_PARAN expression RIGHT_SQ_PARAN
;

%%

int main(int argc, char *argv[]) {
    /*CHECK FOR DEBUGGING REMOVE LATER*/
    /* yydebug = 1; */
    symboltable = createTable();

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
