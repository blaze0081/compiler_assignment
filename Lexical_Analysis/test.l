%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    int line_no = 1;
    int lexical_error = 0;

    // Keywords list for checking if identifier is a keyword
    char *keywords[] = {
        "int", "float", "if", "else", "while", "for", "main", "begin", "end", "input", "output", "program", "VarDecl", "inc", "dec"
    };
    int num_keywords = sizeof(keywords) / sizeof(keywords[0]);

    // Function to check if a string is a keyword
    int is_keyword(char *str) {
        for (int i = 0; i < num_keywords; i++) {
            if (strcmp(str, keywords[i]) == 0) {
                return 1; // True, it's a keyword
            }
        }
        return 0; // False, not a keyword
    }

    // Function to report lexical errors
    void lexicalError(char *message) {
        fprintf(stderr, "Lexical Error at line %d: %s\n", line_no, message);
        lexical_error = 1;
    }

    // Function to validate integer constants
    int validateIntegerConstant(char *value_str, char *base_str) {
        int base = atoi(base_str);
        char *value_part = strtok(strdup(value_str), ","); // Extract value part before comma. strdup is used to create a copy as strtok modifies the string
        char *base_part = strtok(NULL, ","); // Extract base part after comma

        if (value_part == NULL || base_part == NULL || strtok(NULL, ",") != NULL) { // Check if format is (value, base) and nothing more
            lexicalError("Invalid integer constant format: Missing or incorrect base or extra components.");
            free(value_str); // free duplicated string
            return 0;
        }

        if (atoi(base_part) == 0 && strcmp(base_part, "0") != 0) { // Check if base is a valid number. atoi returns 0 if not a number or '0', but "0" is valid case
             lexicalError("Invalid integer constant format: Base is not a valid integer.");
             free(value_str); // free duplicated string
             free(value_part);
             return 0;
        }

        base = atoi(base_part);


        if (base != 2 && base != 8 && base != 10) {
            lexicalError("Invalid integer constant format: Base must be 2, 8, or 10.");
            free(value_str); // free duplicated string
            free(value_part);
            return 0;
        }

        char *digit_set;
        int max_digit;
        if (base == 2) {
            digit_set = "01";
            max_digit = '1';
        } else if (base == 8) {
            digit_set = "01234567";
            max_digit = '7';
        } else { // base == 10
            digit_set = "0123456789";
            max_digit = '9';
        }

        for (int i = 0; value_part[i] != '\0'; i++) {
            if (strchr(digit_set, value_part[i]) == NULL) {
                lexicalError("Invalid integer constant format: Digit not allowed in base.");
                free(value_str); // free duplicated string
                free(value_part);
                return 0;
            }
        }
        free(value_str); // free duplicated string
        free(value_part);
        return 1; // Valid integer constant
    }

    int valid_identifier(char *identifier) {
        if (identifier == NULL || strlen(identifier) == 0) return 0;
        if (!(identifier[0] >= 'a' && identifier[0] <= 'z')) return 0; // Must start with lowercase

        int underscore_count = 0;
        for (int i = 0; identifier[i] != '\0'; i++) {
            if (!((identifier[i] >= 'a' && identifier[i] <= 'z') || (identifier[i] >= '0' && identifier[i] <= '9') || identifier[i] == '_')) {
                return 0; // Invalid character
            }
            if (identifier[i] == '_') {
                underscore_count++;
            }
        }
        if (underscore_count > 1) return 0; // At most one underscore
        return 1;
    }


%}

DIGIT [0-9]
BINARY_DIGIT [01]
OCTAL_DIGIT [0-7]
LOWER_ALPHA [a-z]
UPPER_ALPHA [A-Z]
IDENTIFIER {LOWER_ALPHA}({LOWER_ALPHA}|{DIGIT}|"_")?
DECIMAL_CONSTANT {DIGIT}+
BINARY_CONSTANT {BINARY_DIGIT}+
OCTAL_CONSTANT {OCTAL_DIGIT}+
INTEGER_CONSTANT "("({DECIMAL_CONSTANT}|{BINARY_CONSTANT}|{OCTAL_CONSTANT})","(10|2|8)")"
CHAR_CONSTANT '\''([^'\\\n]|"\\".)*'\''
STRING_CONSTANT \"([^"\\\n]|"\\".)*\"
OPERATOR "+"|"-"|"*"|"/"|"%"|"="|">"|"<"|">="|"<="|"<>"|":="|"+="|"-="|"*="|"/="|"%="
SEPARATOR [();{},"]
SPECIAL_SYMBOL "@"|"_"
KEYWORD "int"|"float"|"if"|"else"|"while"|"for"|"main"|"begin"|"end"|"input"|"output"|"program"|"VarDecl"|"inc"|"dec"
COMMENT_SL "//".*
COMMENT_ML "/*"(.|\n)*"*/"
WHITESPACE [ \t\r\f\v]+

%%
{WHITESPACE}           { /* Ignore whitespace */ }
{COMMENT_SL}           { /* Ignore single-line comments */ }
{COMMENT_ML}           { /* Ignore multi-line comments */ }

{KEYWORD}             { printf("KEYWORD\t\t%s\n", yytext); if(is_keyword(yytext)){} else {lexicalError("Invalid Keyword");}}
"int"|"char"          { printf("DATA_TYPE\t\t%s\n", yytext); }
{OPERATOR}            { printf("OPERATOR\t\t%s\n", yytext); }
{SEPARATOR}           { printf("SEPARATOR\t\t%s\n", yytext); }
{SPECIAL_SYMBOL}      { printf("SPECIAL_SYMBOL\t\t%s\n", yytext); }

{INTEGER_CONSTANT}    {
                            printf("INTEGER_CONSTANT\t%s\t", yytext);
                            char *temp_str = strdup(yytext); // Duplicate string for strtok (as it modifies string)
                            char *value_base_part = strtok(temp_str, "()"); // Get content inside parenthesis.
                            if (value_base_part != NULL) {
                                char *value_str = strtok(value_base_part, ")"); // Get value, base string.
                                if (value_str != NULL) {
                                    char *comma_pos = strchr(value_str, ',');
                                    if (comma_pos != NULL) {
                                        char *base_ptr = comma_pos + 1;
                                        *comma_pos = '\0'; //split value and base
                                        if(validateIntegerConstant(strdup(value_str), base_ptr)) { //strdup for validation, as function frees the memory.
                                            printf("(Value:%s, Base:%s)\n", value_str, base_ptr);
                                        } else {
                                            // Error already reported by validateIntegerConstant
                                        }
                                    } else {
                                        lexicalError("Invalid integer constant format: Comma missing in (value, base).");
                                    }
                                } else {
                                    lexicalError("Invalid integer constant format: Value and base missing.");
                                }
                            } else {
                                 lexicalError("Invalid integer constant format: Missing parenthesis.");
                            }
                            free(temp_str); // Free allocated memory by strdup
                        }

{CHAR_CONSTANT}       { printf("CHAR_CONSTANT\t\t%s\n", yytext); }
{STRING_CONSTANT}     { printf("STRING_CONSTANT\t\t%s\n", yytext); }

{IDENTIFIER}          {
                            if (is_keyword(yytext)) {
                                lexicalError("Keyword used as variable name.");
                            } else if (valid_identifier(yytext)) {
                                printf("IDENTIFIER\t\t%s\n", yytext);
                            }
                             else {
                                lexicalError("Invalid identifier format.");
                            }
                        }

{DECIMAL_CONSTANT}    { printf("DECIMAL_NUMBER\t\t%s (Assuming Decimal Base)\n", yytext); } // If decimal constant is not inside INTEGER_CONSTANT format, assume decimal base, and print a warning.
{BINARY_CONSTANT}     { lexicalError("Invalid binary constant outside integer constant format (base missing)."); }
{OCTAL_CONSTANT}      { lexicalError("Invalid octal constant outside integer constant format (base missing)."); }


\n                    { line_no++; }
.                     { lexicalError("Invalid character."); }

%%

int main(int argc, char *argv[]) {
    if (argc > 1) {
        if (!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return 1;
        }
    }

    yylex();

    if (lexical_error == 0) {
        printf("\nLexical analysis successful. No errors found.\n");
    } else {
        printf("\nLexical analysis completed with errors.\n");
    }

    return lexical_error;
}

int yywrap() {
    return 1;
}