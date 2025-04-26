%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol.h"                     /* ← NEW: your symbol-table API */
extern FILE *yyin;
extern int yylineno;
extern int yylex(void);
void yyerror(const char *s);

table *symboltable;                    /* ← NEW: global symbol table */
%}

%union {
    int    type;      /* for Pascal types (TY_INT, etc.) */
    int    ival;      /* for integer constants */
    int    value; 
    char   str[100];  /* for identifiers & string literals */
}

/*–– tokens carrying semantic values ––*/
%token <str> IDENTIFIER IO_STRING_CONSTANT CHAR_CONSTANT
%token <ival> INTEGER_CONSTANT

/*–– keywords and punctuators ––*/
%token PROGRAM VARDECL T_BEGIN END PRINT SCAN DIGIT
%token INT CHAR IF ELSE WHILE FOR DO TO INC DEC
%token ASSIGN_EQUALS PLUS_EQUALS MINUS_EQUALS MULT_EQUALS DIV_EQUALS MODULO_EQUALS
%token LESS_EQUALS GREATER_EQUALS NOT_EQUALS LESS GREATER EQUALS
%token PLUS MINUS MULT DIV MODULO
%token LEFT_ROUND_PARAN RIGHT_ROUND_PARAN LEFT_SQ_PARAN RIGHT_SQ_PARAN
%token SEMI_COLON COMMA COLON

/*–– nonterminals ––*/
%type <type> type 
%type <ival>    expression


/* precedence */
%left PLUS MINUS MULT DIV MODULO
%left LESS_EQUALS LESS GREATER GREATER_EQUALS
%right ASSIGN_EQUALS

%%

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
      /* empty */
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
;

type:
      INT  { $$ = TY_INT; }
    | CHAR { $$ = TY_CHAR; }
;

statement_list:
      /* empty */
    | statement_list statement
;

statement:
      assignment_statement
    | input_output_statement
    | IF LEFT_ROUND_PARAN expression RIGHT_ROUND_PARAN DO statement_list END  /* simple if */
    | WHILE LEFT_ROUND_PARAN expression RIGHT_ROUND_PARAN DO statement_list END
    | FOR IDENTIFIER ASSIGN_EQUALS expression TO expression DO statement_list END
;

assignment_statement:
    IDENTIFIER ASSIGN_EQUALS expression SEMI_COLON
    {
        if (!searchEntry(symboltable, $1)) {
            printf("Error: Undeclared variable '%s'\n", $1);
        } else {
            setEntry(symboltable, $1);
            setEntryValue(symboltable, $1, $3);
            int destT = getEntryType(symboltable, $1);
            if (destT != $3)
                printf("Error: Type mismatch in assignment to '%s'\n", $1);
        }
    }
;

input_output_statement:
      PRINT LEFT_ROUND_PARAN IO_STRING_CONSTANT COMMA IDENTIFIER RIGHT_ROUND_PARAN SEMI_COLON
    {
        printf("print(%s, %s)\n", $3, $5);
    }
    | PRINT LEFT_ROUND_PARAN IO_STRING_CONSTANT RIGHT_ROUND_PARAN SEMI_COLON
    {
        printf("print(%s)\n", $3);
    }
    | SCAN LEFT_ROUND_PARAN IDENTIFIER RIGHT_ROUND_PARAN SEMI_COLON
    {
        if (!searchEntry(symboltable, $3)) {
            printf("Error: Undeclared variable '%s'\n", $3);
        } else {
            setEntry(symboltable, $3);
            printf("scan(%s)\n", $3);
        }
    }
;

expression:
    INTEGER_CONSTANT
    {
      /* yylval.ival was set by your lexer, so just pass it through */
      $$ = $1;
    }
  | IDENTIFIER
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
  | expression PLUS expression
    {
      $$ = $1 + $3;
    }
  /* …and similarly for MINUS, MULT, DIV, etc. */
;


%%

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input-file>\n", argv[0]);
        return 1;
    }
    /* initialize symbol table BEFORE parsing */
    symboltable = createTable();

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
