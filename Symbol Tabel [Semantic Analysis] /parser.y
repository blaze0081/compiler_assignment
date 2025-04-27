%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern FILE* yyin;
extern int yylineno;
extern int yylex(void);
void yyerror(const char *s);
#include "symbol.h" 
#include "ast.h"

extern Node* myhead;
%}

%code requires {
    #include "ast.h"
    #include "symbol.h"
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
        /* build AST */
        $$ = createNode();
        setname($$, "PROGRAM");
        addchild($$, $4);
        addchild($$, $5);
        myhead = $$;

        /* print generalized AST */
        dfs(myhead);
        // print_generalized(myhead, 0);
        printf("\n");

        /*  
         * 1) create symbol table  
         * 2) interpret (exec) the AST  
         * 3) print final symbol table  
         */
        printf("\n--- Program Output ---\n");
        SymbolTable* symtab = create_symbol_table();
        interpret_program(myhead, symtab);

        printf("\n");
        print_symbol_table(symtab);
        destroy_symbol_table(symtab);
        free_ast(myhead);

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
        $$=$3;
    }
    | SCAN LEFT_ROUND_PARAN scan_arguments RIGHT_ROUND_PARAN
    {
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
    WHILE LEFT_ROUND_PARAN condition RIGHT_ROUND_PARAN DO block_statement
    {
         $$=createNode();
        setname($$,"WHILE");
        addchild($$,$3);
        addchild($$,$6);
    }
    | WHILE LEFT_ROUND_PARAN condition RIGHT_ROUND_PARAN block_statement
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
    | expression arithmatic_operator factor
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

/* Helper prototypes */
void interpret_program(Node* root, SymbolTable* table);
void execute_statements(Node* stmts, SymbolTable* table);
void execute_statement(Node* stmt, SymbolTable* table);
int  eval_expr(Node* expr, SymbolTable* table);
int  eval_condition(Node* cond, SymbolTable* table);
void free_ast(Node* root);

/*  
 * Entry point: first child is var‐decl, second is statement list  
 */
void interpret_program(Node* root, SymbolTable* table) {
    /* 1) insert all declared variables */
    Node* vars  = root->children[0];
    for (int i = 0; i < vars->n; i++) {
        Node* v = vars->children[i];
        const char* type = v->name;               /* "int" or "char" */
        const char* name = v->children[0]->name;  /* identifier */
        insert_symbol(table, name,
            strcmp(type,"int")==0 ? TYPE_INT : TYPE_CHAR
        );
    }
    /* 2) execute all statements */
    execute_statements(root->children[1], table);
}

/* execute a sequence of statements */
void execute_statements(Node* stmts, SymbolTable* table) {
    for (int i = 0; i < stmts->n; i++) {
        execute_statement(stmts->children[i], table);
    }
}

/* dispatch on statement kind */
void execute_statement(Node* stmt, SymbolTable* table) {
    const char* op = stmt->name;

    if (strcmp(op, ":=")==0
     || strcmp(op, "+=")==0
     || strcmp(op, "-=")==0
     || strcmp(op, "*=")==0
     || strcmp(op, "/=")==0
     || strcmp(op, "%=")==0)
    {
        /* assignment */
        const char* name = stmt->children[0]->children[0]->name;
        int rhs = eval_expr(stmt->children[1], table);

        if (strcmp(op, ":=")==0) {
            set_symbol_int(table, name, rhs);
        }
        else {
            Symbol* s = lookup_symbol(table, name);
            if (!s->is_initialized) {
                fprintf(stderr, "Semantic Error: '%s' used before init\n", name);
                exit(1);
            }
            if (strcmp(op, "+=")==0) set_symbol_int(table, name, s->int_val + rhs);
            if (strcmp(op, "-=")==0) set_symbol_int(table, name, s->int_val - rhs);
            if (strcmp(op, "*=")==0) set_symbol_int(table, name, s->int_val * rhs);
            if (strcmp(op, "/=")==0) set_symbol_int(table, name, s->int_val / rhs);
            if (strcmp(op, "%=")==0) set_symbol_int(table, name, s->int_val % rhs);
        }
        return;
    }
    else if (strcmp(op, "Branch")==0) {
        /* if / if‐else */
        Node* cond = stmt->children[0];
        int condv = eval_condition(cond, table);
        if (stmt->n == 2) {
            if (condv) execute_statement(stmt->children[1], table);
        } else {
            if (condv) execute_statement(stmt->children[1], table);
            else        execute_statement(stmt->children[2], table);
        }
        return;
    }
    else if (strcmp(op, "WHILE")==0) {
        Node* cond  = stmt->children[0];
        Node* block = stmt->children[1];
        while (eval_condition(cond, table)) {
            Symbol* s = lookup_symbol(table, "number");
            execute_statement(block, table);
        }
        return;
    }
    else if (strcmp(op, "Block")==0) {
        /* a block is just a wrapped statement_list */
        execute_statements(stmt->children[0], table);
        return;
    }
    
    /* else if (strcmp(op, "Print")==0) {
        Node* first = stmt->children[0];
        const char* lit = first->children[0]->name;
        int len = strlen(lit);
        if (len >= 2 && lit[0]=='\"' && lit[len-1]=='\"') {
            fwrite(lit+1, 1, len-2, stdout);
        } else {
            printf("%s", lit);
        }
        if (stmt->n > 1) {
            Node* list = stmt->children[1];
            for (int i = 0; i < list->n; i++) {
                int v = eval_expr(list->children[i], table);
                printf(" %d", v);
            }
        }
        printf("\n");
        return;
    } */
    
    else if (strcmp(op, "FOR") == 0) {
        /* child[0]=var, [1]=start, [2]=expr_check, [3]=block */
        const char* varname = stmt->children[0]->children[0]->name;
        int start = eval_expr(stmt->children[1], table);

        Node* ec = stmt->children[2];        // bound+step node
        int bound, step;
        if (strcmp(ec->name, "inc") == 0) {
            bound = eval_expr(ec->children[0], table);
            step  = eval_expr(ec->children[1], table);
        } else {  // "dec"
            bound = eval_expr(ec->children[0], table);
            step  = -eval_expr(ec->children[1], table);
        }

        /* initialize loop var */
        set_symbol_int(table, varname, start);

        /* loop until we pass bound (inclusive) */
        if (step > 0) {
            while ( lookup_symbol(table, varname)->int_val <= bound ) {
                execute_statement(stmt->children[3], table);
                int cur = lookup_symbol(table, varname)->int_val;
                set_symbol_int(table, varname, cur + step);
            }
        } else {
            while ( lookup_symbol(table, varname)->int_val >= bound ) {
                execute_statement(stmt->children[3], table);
                int cur = lookup_symbol(table, varname)->int_val;
                set_symbol_int(table, varname, cur + step);
            }
        }
        return;
    }

    else {
        /* catch‐all: maybe a nested block or single statement_list */
        for (int i = 0; i < stmt->n; i++) {
            execute_statement(stmt->children[i], table);
        }
    }
}

/* in parser.y, replace your eval_expr with: */
int eval_expr(Node* expr, SymbolTable* table) {
    /* 1) INTCONST / DIGIT are genuine leaves */
    if (strcmp(expr->name, "INTCONST") == 0
     || strcmp(expr->name, "DIGIT")    == 0) {
        return expr->ival;
    }

    /* 2) Single-child: just a wrapper (parenthesis or variable_name) */
    if (expr->n == 1) {
        return eval_expr(expr->children[0], table);
    }

    /* 3) Zero-child: must be an identifier leaf → do a lookup */
    if (expr->n == 0) {
        const char* varname = expr->name;
        Symbol* s = lookup_symbol(table, varname);
        if (!s) {
            fprintf(stderr, "Semantic Error: '%s' not declared\n", varname);
            exit(1);
        }
        if (!s->is_initialized) {
            fprintf(stderr, "Semantic Error: '%s' used before init\n", varname);
            exit(1);
        }
        return s->int_val;
    }

    /* 4) Two-child: binary arithmetic */
    if (expr->n == 2) {
        int L = eval_expr(expr->children[0], table);
        int R = eval_expr(expr->children[1], table);
        if      (strcmp(expr->name, "+") == 0) return L + R;
        else if (strcmp(expr->name, "-") == 0) return L - R;
        else if (strcmp(expr->name, "*") == 0) return L * R;
        else if (strcmp(expr->name, "/") == 0) return L / R;
        else if (strcmp(expr->name, "%") == 0) return L % R;
    }

    /* Anything else is a logic error */
    fprintf(stderr,
        "Internal Error: unexpected expr node '%s' with %d children\n",
        expr->name, expr->n
    );
    exit(1);
}



/* evaluate a boolean condition */
int eval_condition(Node* cond, SymbolTable* table) {
    if (cond->n == 2) {
        int L = eval_expr(cond->children[0], table);
        int R = eval_expr(cond->children[1], table);
        if      (strcmp(cond->name, "=")==0) return L == R;
        else if (strcmp(cond->name,"<>")==0) return L != R;
        else if (strcmp(cond->name,">")==0)  return L > R;
        else if (strcmp(cond->name,"<")==0)  return L < R;
        else if (strcmp(cond->name,">=")==0) return L >= R;
        else if (strcmp(cond->name,"<=")==0) return L <= R;
    }
    else if (cond->n == 1) {
        return eval_expr(cond->children[0], table) != 0;
    }
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Syntax Error\n");
}

/* post-order free of all AST nodes */
void free_ast(Node* root) {
    if (!root) return;
    for (int i = 0; i < root->n; i++) {
        free_ast(root->children[i]);
    }
    free(root);
}


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


