#include "symbol.h" 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdbool.h>


// typedef enum {
//     TY_INT,    // integer
//     TY_REAL,  // real
//     TY_CHAR,   // char
//     TY_BOOL   // boolean
// } Type;

// typedef struct entry {
//     char *id;
//     Type type;
//     bool isfunc;
//     struct entry *next;  // For handling collisions or chaining in the future
// } entry;

// typedef struct table {
//     struct table *parent;
//     entry *entries[100];  // Simple fixed size for demonstration
//     int numEntries;
// } table;

table *createTable() {
    table *newTable = malloc(sizeof(table));
    if (!newTable) {
        fprintf(stderr, "Memory allocation failed for symbol table.\n");
        exit(1);
    }
    newTable->numEntries = 0;
    memset(newTable->entries, 0, sizeof(newTable->entries));
    return newTable;
}

entry *createEntry(char *id, int i) {
    entry *newEntry = malloc(sizeof(entry));
    if (!newEntry) {
        fprintf(stderr, "Memory allocation failed for table entry.\n");
        exit(1);
    }
    newEntry->id = strdup(id);
    newEntry->type = i;
    newEntry->isSet = false;
    newEntry->value = 0;     // default
    return newEntry;
}


bool insertEntry(table *t, char *id, int i) {
    if(searchEntry(t,id))
    return false;
    entry *newEntry = createEntry(id, i);
    t->entries[t->numEntries] = newEntry;
    t->numEntries++;
    return true;
}

bool searchEntry(table *t, char *id) {
    
    for(int i=0; i<t->numEntries; i++)
    {
        if (strcmp(t->entries[i]->id, id) == 0)
            return true; 
    }
    return false;
}

int getEntryType(table *t, char *id) {
    for(int i=0; i<t->numEntries; i++)
    {
        if (strcmp(t->entries[i]->id, id) == 0)
            return t->entries[i]->type; 
    }
    return -1;
}

void checkEntry(table *t, char *id)
{
    if(getEntryType(t, id)==-1)
    printf("Variable - %s is not declared \n",id);
}
void setEntry(table *t, char *id)
{
    bool success =false;
    for(int i=0; i<t->numEntries; i++)
    {
        if (strcmp(t->entries[i]->id, id) == 0)
        {
            success=true;
            t->entries[i]->isSet=true;
            return ;
        }     
    }
    if(!success)
    printf("Variable - %s is not declared \n",id);
}
bool checkisSet(table*t,char *id)
{
   for(int i=0; i<t->numEntries; i++)
    {
        if (strcmp(t->entries[i]->id, id) == 0)
        {
            return t->entries[i]->isSet ;
        }     
    }
    return false; 
}
void checkSet(table *t, char *id)
{
    if(getEntryType(t,id)==-1)
    printf("Variable - %s is not declared \n",id);
    else
    {
        if(!checkisSet(t,id))
        printf("Use of variable- %s without initializing \n",id);
    }

}

// in symbol.c
void setEntryValue(table *t, char *id, int val) {
        for(int i=0; i < t->numEntries; i++){
            if (strcmp(t->entries[i]->id, id) == 0) {
                t->entries[i]->isSet = true;
                t->entries[i]->value = val;
                return;
            }
        }
        printf("Variable - %s is not declared\n", id);
    }

    int getEntryValue(table *t, char *id) {
        for(int i = 0; i < t->numEntries; i++) {
            if (strcmp(t->entries[i]->id, id) == 0)
                return t->entries[i]->value;
        }
        return 0;  /* or error out */
    }

    
// int main() {
//     table *symbolTable = createTable();
//     insertEntry(symbolTable, "x", TY_INT);
//     insertEntry(symbolTable, "y", TY_REAL);
//     insertEntry(symbolTable, "flag", TY_BOOL);
//     insertEntry(symbolTable, "ch", TY_CHAR);

//     printf("x is of type %d\n", getEntryType(symbolTable, "x"));
//     printf("y is of type %d\n", getEntryType(symbolTable, "y"));
//     printf("flag is of type %d\n", getEntryType(symbolTable, "flag"));
//     printf("ch is of type %d\n", getEntryType(symbolTable, "ch"));

//     return 0;
// }
