#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>


void validateIntConstant(const char *text) {
    int len = strlen(text);
    if (len < 5) {
        printf("%-25s Error: invalid integer constant\n", text);
        exit(1);
    }
    
    char inner[256];
    strncpy(inner, text+1, len-2);
    inner[len-2] = '\0';
    
    char *comma = strchr(inner, ',');
    if (!comma) {
        printf("%-25s Error: invalid integer constant\n", text);
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
        printf("%-25s Error: invalid integer constant\n", text);
        exit(1);
    }
    
    int baseNum = atoi(base);
    if (baseNum != 2 && baseNum != 8 && baseNum != 10) {
        printf("%-25s Error: invalid integer constant\n", text);
        exit(1);
    }
    
    for (int i = 0; value[i] != '\0'; i++) {
        if (!isdigit(value[i])) {
            printf("%-25s Error: invalid integer constant\n", text);
            exit(1);
        }
        int digit = value[i] - '0';
        if (baseNum == 8 && digit > 7) {
            printf("%-25s Error: invalid integer constant\n", text);
            exit(1);
        }
        if (baseNum == 2 && digit > 1) {
            printf("%-25s Error: invalid integer constant\n", text);
            exit(1);
        }
    }
    /*CORRECT INT_CONSTANT*/
}

/* Count occurrences of @ in a string */
int countAtSymbols(const char *str) {
    int count = 0;
    char *ptr = strchr(str, '@');
    while (ptr != NULL) {
        count++;
        ptr = strchr(ptr + 1, '@');
    }
    return count;
}

int countCommaSymbols(const char *str) {
    int count = 0;
    char *ptr = strchr(str, ',');
    while (ptr != NULL) {
        count++;
        ptr = strchr(ptr + 1, ',');
    }
    return count;
}

/* Count number of arguments (values after the format string) */
int countArgs(const char *str) {
    int count = 0;
    const char *ptr = str;
    int in_string = 0;
    
    // Skip until after the first string
    while (*ptr) {
        if (*ptr == '"') {
            in_string = !in_string;
            if (!in_string) {
                ptr++;
                break;
            }
        }
        ptr++;
    }
    
    // Count commas outside of strings and constants
    int in_const = 0;
    while (*ptr) {
        if (*ptr == '(') in_const = 1;
        else if (*ptr == ')') in_const = 0;
        else if (*ptr == '"') in_string = !in_string;
        else if (*ptr == ',' && !in_string && !in_const) count++;
        ptr++;
    }
    
    return count ;  // Add 1 because commas are one less than arguments
}


void validateIO(const char *text, int is_scan) {
    printf("%s\n", text);
    // Check for semicolon at the end
    size_t len = strlen(text);
    
    // Find the first string
    char *start_quote = strchr(text, '"');
    char *end_quote = start_quote ? strchr(start_quote + 1, '"') : NULL;
    
    if (!start_quote || !end_quote) {
        switch(is_scan){
            case 0:
                printf("%-25s  Error: invalid input statement [incomplete line]\n", text);
            case 1:
                printf("%-25s  Error: invalid output statement [incomplete line]\n", text);
        }
        exit(1);
    }
    
    // Extract and check the format string
    size_t format_len = end_quote - start_quote - 1;
    char format_str[256] = {0};
    strncpy(format_str, start_quote + 1, format_len);
    
    int at_count = countAtSymbols(format_str);
    int arg_count = countArgs(text);
    int comma_count = countCommaSymbols(format_str);

    // print("comma:, %d", comma_count); LEGAL STATEMENT
    if (is_scan && (comma_count != arg_count-1)) {
            printf("%-25s  Error: invalid input statement [comma count does NOT match arguments]\n", text);
        exit(1);
    }

    if (at_count != arg_count) {
        switch(is_scan){
            case 0:
                printf("%-25s  Error: invalid input statement [@ count %d does NOT match argument count %d ]\n", text, at_count, arg_count);
                break;
            case 1:
                printf("%-25s  Error: invalid output statement [@ count %d does NOT match argument count %d ]\n", text, at_count, arg_count);
                break;
        }
        exit(1);
    }
    
    if (is_scan) {
        // For scan, all arguments must be identifiers
        char *ptr = end_quote + 1;
        while (*ptr) {
            if (*ptr == '(' || *ptr == '\'' || *ptr == '"') {
                printf("%-25s  Error: invalid input statement [invalid declaration]\n", text);
                exit(1);
            }
            ptr++;
        }
    }
    
    if (is_scan) {
        printf("%-25s Valid input statements\n", text);
    } else {
        printf("%-25s Valid output statement\n", text);
    }
    return;
    
    /*VALID INPUT_OUTPUT STATEMENT*/
}