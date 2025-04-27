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
    // 1) Compute max widths
    int name_w  = strlen("Name");
    int type_w  = strlen("Type");
    int value_w = strlen("Value");
    for (Symbol* s = table->head; s; s = s->next) {
        int len = strlen(s->name);
        if (len > name_w) name_w = len;
        const char* t = (s->type == TYPE_INT ? "int" : "char");
        if ((len = strlen(t)) > type_w) type_w = len;
        char buf[64];
        if (s->type == TYPE_INT) {
            if (s->is_initialized) snprintf(buf, sizeof buf, "%d", s->int_val);
            else                    snprintf(buf, sizeof buf, "uninit");
        } else {
            if (s->is_initialized) snprintf(buf, sizeof buf, "'%c'", s->char_val);
            else                    snprintf(buf, sizeof buf, "uninit");
        }
        if ((len = strlen(buf)) > value_w) value_w = len;
    }

    // 2) Compute total width: 
    //    4 vertical bars + 3 columns each padded by 2 spaces
    int table_w = 4 + (name_w + 2) + (type_w + 2) + (value_w + 2);

    // 3) Top border of '='
    for (int i = 0; i < table_w; i++) putchar('=');
    putchar('\n');

    // 4) Centered title
    const char title[] = " Symbol Table ";
    int pad = (table_w - (int)strlen(title)) / 2;
    for (int i = 0; i < pad; i++) putchar('=');
    fputs(title, stdout);
    for (int i = 0; i < table_w - pad - (int)strlen(title); i++) putchar('=');
    putchar('\n');

    // 5) Header row
    printf("| %-*s | %-*s | %-*s |\n",
           name_w,  "Name",
           type_w,  "Type",
           value_w, "Value");

    // 6) Separator of '-'
    for (int i = 0; i < table_w; i++) putchar('-');
    putchar('\n');

    // 7) Each symbol
    for (Symbol* s = table->head; s; s = s->next) {
        char val_buf[64];
        if (s->type == TYPE_INT) {
            if (s->is_initialized) snprintf(val_buf, sizeof val_buf, "%d", s->int_val);
            else                    snprintf(val_buf, sizeof val_buf, "uninit");
        } else {
            if (s->is_initialized) snprintf(val_buf, sizeof val_buf, "'%c'", s->char_val);
            else                    snprintf(val_buf, sizeof val_buf, "uninit");
        }
        printf("| %-*s | %-*s | %-*s |\n",
               name_w,  s->name,
               type_w,  (s->type == TYPE_INT ? "int" : "char"),
               value_w, val_buf);
    }

    // 8) Bottom border of '='
    for (int i = 0; i < table_w; i++) putchar('=');
    putchar('\n');
}


