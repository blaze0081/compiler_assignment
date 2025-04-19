#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

#define MAX_ID_LEN 100
#define MAX_SYMBOLS 1000

typedef struct Symbol {
    char name[MAX_ID_LEN];
    char type[10]; /* "int" or "char" */
} Symbol;

Symbol symbols[MAX_SYMBOLS];

int symbolCount = 0;  /* number of declared variables */


/* Check if a string is a keyword */
int isKeyword(const char *str) {
    const char *keywords[] = {
        "int", "char", "if", "else", "while", "for", "main",
        "begin", "end", "print", "scan", "program", "VarDecl", "inc", "dec"
    };
    int numKeywords = sizeof(keywords) / sizeof(keywords[0]);
    for (int i = 0; i < numKeywords; i++) {
        if (strcmp(str, keywords[i]) == 0)
            return 1;
    }
    return 0;
}

void addSymbol(const char *name, const char *type) {
    /* Check for duplicate definition */
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbols[i].name, name) == 0) {
            printf("Syntax Error\n");
            exit(1);
        }
    }
    
    /* Check if keyword is used as variable */
    if (isKeyword(name)) {
        printf("Syntax Error\n");
        exit(1);
    }
    
    /* Check underscore count */
    int underscoreCount = 0;
for (int i = 0; name[i] != '\0'; i++) {
        if (name[i] == '_')
            underscoreCount++;
    }
    if (underscoreCount > 1) {
        printf("Syntax Error\n");
        exit(1);
    }

    else{
        strcpy(symbols[symbolCount].name, name);
        strcpy(symbols[symbolCount].type, type);
        symbolCount++;
    }

}

void isDeclared(const char *name) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbols[i].name, name) != 0){
            printf("Syntax Error\n");
            exit(1);
        }
    }
}

void validateIntConstant(const char *text) {
    int len = strlen(text);
    if (len < 5) {
        // printf("%-25s Error: invalid integer constant\n", text);
        printf( "Syntax Error\n");
        exit(1);
    }
    
    char inner[256];
    strncpy(inner, text+1, len-2);
    inner[len-2] = '\0';
    
    char *comma = strchr(inner, ',');
    if (!comma) {
        // printf("%-25s Error: invalid integer constant\n", text);
        printf( "Syntax Error\n");
        exit(1);
    }
    
    *comma = '\0';
    char *value = inner;
    char *base = comma + 1;
    
    while(isspace(*value)) value++;
    while(isspace(*base)) base++;
    char *endPtr = base + strlen(base) - 1;
    while(endPtr > base && isspace(*endPtr)) { *endPtr = '\0'; endPtr--; }
    
    if (strlen(value) == 0 || strlen(base) == 0) {
        // printf("%-25s Error: invalid integer constant\n", text);
        printf( "Syntax Error\n");
        exit(1);
    }
    
    int baseNum = atoi(base);
    if (baseNum != 2 && baseNum != 8 && baseNum != 10) {
        // printf("%-25s Error: invalid integer constant\n", text);
        printf( "Syntax Error\n");
        exit(1);
    }
    
    for (int i = 0; value[i] != '\0'; i++) {
        if (!isdigit(value[i])) {
            // printf("%-25s Error: invalid integer constant\n", text);
            printf( "Syntax Error\n");
            exit(1);
        }
        int digit = value[i] - '0';
        if (baseNum == 8 && digit > 7) {
            // printf("%-25s Error: invalid integer constant\n", text);
            printf( "Syntax Error\n");
            exit(1);
        }
        if (baseNum == 2 && digit > 1) {
            // printf("%-25s Error: invalid integer constant\n", text);
            printf( "Syntax Error\n");
            exit(1);
        }
    }
    /*CORRECT INT_CONSTANT*/
}


void validateIO(const char* format, char** args, int arg_count, int isScan) {
    int expected_args = 0;
    for (int i = 0; format[i] != '\0'; i++) {
        if (format[i] == '@') expected_args++;
    }

    if (expected_args != arg_count) {
        printf( "Syntax Error\n");
        exit(1);
    }
}
