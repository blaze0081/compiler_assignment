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
void arithematic_comp(struct data1* lhs, struct data1 rhs1, struct data1 rhs2, int* n,char *s);
void array_handle(struct data1* lhs, struct data1 rhs1, struct data1 rhs2, int* n);
void assignment_handle(struct data1* lhs, struct data1 rhs1, struct data1 rhs2, int* n) ;
void conditional_handle(struct data1* lhs, struct data1 rhs1, struct data1 rhs2,int* n, char*s);
void conditional_handle_not(struct data1* lhs, struct data1 rhs1,int* n);
void handle_rec_st(struct data1* lhs,struct data1 rhs1,struct data1 rhs2);
void conditional_if(struct data1* lhs,struct data1 rhs1,struct data1 rhs2);
void conditional_if_else(struct data1* lhs,struct data1 rhs1,struct data1 rhs2,struct data1 rhs3);
void while_handler (struct data1* lhs,struct data1 rhs1,struct data1 rhs2);
void for_to(struct data1* lhs,struct data1 rhs1,struct data1 rhs2,struct data1 rhs3,struct data1 rhs4);
void for_downto(struct data1* lhs,struct data1 rhs1,struct data1 rhs2,struct data1 rhs3,struct data1 rhs4);
void read_handle(struct data1* lhs,struct data1 rhs);
#endif 
