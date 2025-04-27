#ifndef SYMBOL_H
#define SYMBOL_H

#include <stdbool.h>

typedef enum { TYPE_INT, TYPE_CHAR } VarType;

typedef struct Symbol {
    char        name[32];
    VarType     type;
    int         int_val;
    char        char_val;
    bool        is_initialized;
    struct Symbol* next;
} Symbol;

typedef struct {
    Symbol* head;
} SymbolTable;

// Create/destroy
SymbolTable*   create_symbol_table();
void           destroy_symbol_table(SymbolTable* table);

// Manipulate
void           insert_symbol(SymbolTable* table, const char* name, VarType type);
Symbol*        lookup_symbol(SymbolTable* table, const char* name);
void           set_symbol_int(SymbolTable* table, const char* name, int value);
void           set_symbol_char(SymbolTable* table, const char* name, char value);

// Dump
void           print_symbol_table(SymbolTable* table);

#endif /* SYMBOL_H */
