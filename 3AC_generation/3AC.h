#ifndef THREEADDCODE_H
#define THREEADDCODE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// Define the structure 'data' used by the function.
struct data {
    char *code;
    int ival;
    float fval;
    char str[200];
};

// Declare the function prototype for 'arithematic_comp'.
void arithematic_comp(struct data* lhs, struct data rhs1, struct data rhs2, int* n,char *s);
void array_handle(struct data* lhs, struct data rhs1, struct data rhs2, int* n);
void assignment_handle(struct data* lhs, struct data rhs1, struct data sign, struct data rhs2, int* n);
void conditional_handle(struct data* lhs, struct data rhs1, struct data rhs2,int* n, char*s);
void conditional_handle_not(struct data* lhs, struct data rhs1,int* n);
void handle_rec_st(struct data* lhs,struct data rhs1,struct data rhs2);
void conditional_if(struct data* lhs,struct data rhs1,struct data rhs2);
void conditional_if_else(struct data* lhs,struct data rhs1,struct data rhs2,struct data rhs3);
void while_handler (struct data* lhs,struct data rhs1,struct data rhs2);
void for_to(struct data* lhs,struct data rhs1,struct data rhs2,struct data rhs3,struct data rhs4);
void for_downto(struct data* lhs,struct data rhs1,struct data rhs2,struct data rhs3,struct data rhs4);
void read_handle(struct data* lhs,struct data rhs);
#endif 
