#include "symbol.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

SymbolTable* create_symbol_table() {
    SymbolTable* t = malloc(sizeof(SymbolTable));
    t->head = NULL;
    return t;
}

void destroy_symbol_table(SymbolTable* table) {
    Symbol* cur = table->head;
    while (cur) {
        Symbol* tmp = cur->next;
        free(cur);
        cur = tmp;
    }
    free(table);
}

Symbol* lookup_symbol(SymbolTable* table, const char* name) {
    for (Symbol* s = table->head; s; s = s->next) {
        if (strcmp(s->name, name) == 0) return s;
    }
    return NULL;
}

void insert_symbol(SymbolTable* table, const char* name, VarType type) {
    if ( lookup_symbol(table, name) ) {
        fprintf(stderr, "Semantic Error: Variable '%s' already declared\n", name);
        exit(1);
    }
    Symbol* s = malloc(sizeof(Symbol));
    strncpy(s->name, name, sizeof(s->name)-1);
    s->name[sizeof(s->name)-1] = '\0';
    s->type           = type;
    s->int_val        = 0;
    s->char_val       = '\0';
    s->is_initialized = true;
    s->next           = table->head;
    table->head       = s;
}

void set_symbol_int(SymbolTable* table, const char* name, int value) {
    Symbol* s = lookup_symbol(table, name);
    if (!s) {
        fprintf(stderr, "Semantic Error: Variable '%s' not declared\n", name);
        exit(1);
    }
    if (s->type != TYPE_INT) {
        fprintf(stderr, "Type Error: Variable '%s' is not int\n", name);
        exit(1);
    }
    s->int_val        = value;
    s->is_initialized = true;
}

void set_symbol_char(SymbolTable* table, const char* name, char value) {
    Symbol* s = lookup_symbol(table, name);
    if (!s) {
        fprintf(stderr, "Semantic Error: Variable '%s' not declared\n", name);
        exit(1);
    }
    if (s->type != TYPE_CHAR) {
        fprintf(stderr, "Type Error: Variable '%s' is not char\n", name);
        exit(1);
    }
    s->char_val       = value;
    s->is_initialized = true;
}

void print_symbol_table(SymbolTable* table) {
    printf("----- Symbol Table -----\n");
    printf("Name\tType\tValue\n");
    for (Symbol* s = table->head; s; s = s->next) {
        printf("%s\t", s->name);
        if (s->type == TYPE_INT) {
            printf("int\t");
            if (s->is_initialized) printf("%d", s->int_val);
            else                    printf("uninit");
        } else {
            printf("char\t");
            if (s->is_initialized) printf("'%c'", s->char_val);
            else                    printf("uninit");
        }
        printf("\n");
    }
}

