#include<stdio.h>
#include <stdlib.h>
#include <string.h>

#include "3AC.h"
int labelCount=0;
char* newLabel() {
    char* label = (char*) calloc(10,sizeof(char));
    sprintf(label, "L%d", labelCount++);
    return label;
}
void arithematic_comp(struct data* lhs, struct data rhs1, struct data rhs2, int* n,char* s) {
    // Format the temporary variable name
    sprintf(lhs->str, "t%d", *n);
    (*n)++;
    // Build the arithmetic statement
    char *st = calloc(50, sizeof(char));
    strcat(st, lhs->str);
    strcat(st, "=");
    strcat(st, rhs1.str);
    strcat(st, s);
    strcat(st, rhs2.str);
    strcat(st, "\n");

    // Calculate the total length needed for the result
    int len1 = (rhs1.code != NULL) ? strlen(rhs1.code) : 0;
    int len2 = (rhs2.code != NULL) ? strlen(rhs2.code) : 0;
    char *result = calloc(len1 + len2 + strlen(st) + 1, sizeof(char));

    // Concatenate existing code and the new statement
    if (rhs1.code != NULL)
        strcat(result, rhs1.code);
    if (rhs2.code != NULL)
        strcat(result, rhs2.code);
    strcat(result, st);

    // Assign the new code to lhs and free temporary string
    lhs->code = result;
    free(st);
}
void array_handle(struct data* lhs, struct data rhs1, struct data rhs2, int* n){
    sprintf(lhs->str, "t%d", *n);
    (*n)++;
    char *st = calloc(50, sizeof(char));
    strcat(st, lhs->str);
    strcat(st, "=");
    strcat(st, rhs1.str);
    strcat(st, "[");
    strcat(st, rhs2.str);
    strcat(st, "]");
    strcat(st, "\n");
    int len2 = (rhs2.code != NULL) ? strlen(rhs2.code) : 0;
    char *result = calloc( len2 + strlen(st) + 1, sizeof(char));
    if (rhs2.code != NULL)
        strcat(result, rhs2.code);
    strcat(result, st);
    lhs->code = result;
    free(st);
}
void assignment_handle(struct data* lhs, struct data rhs1, struct data sign, struct data rhs2, int* n) {
    char *st = calloc(100, sizeof(char));
    strcat(st, rhs1.str);
    strcat(st, sign.str);
    strcat(st, rhs2.str);
    strcat(st, "\n");
    int len2 = (rhs2.code != NULL) ? strlen(rhs2.code) : 0;
    char *result = calloc(len2 + strlen(st) + 1, sizeof(char));
    if (rhs2.code != NULL)
        strcat(result, rhs2.code);
    strcat(result, st);
    // Assign the new code to lhs and free temporary string
    lhs->code = result;
    free(st);
}
void assignment_handlearray(struct data* lhs, struct data rhs1, struct data rhs2,struct data rhs3, int* n) {
    char *st = calloc(50, sizeof(char));
    strcat(st, rhs1.str);
    strcat(st, "[");
    strcat(st, rhs2.str);
    strcat(st, "]");
    strcat(st, ":=");
    strcat(st, rhs3.str);
    strcat(st, "\n");
    int len2 = (rhs2.code != NULL) ? strlen(rhs2.code) : 0;
    int len3 = (rhs3.code != NULL) ? strlen(rhs3.code) : 0;
    char *result = calloc(len2 + len3+ strlen(st) + 1, sizeof(char));
    if (rhs2.code != NULL)
        strcat(result, rhs2.code);
    if (rhs3.code != NULL)
        strcat(result, rhs3.code);
    strcat(result, st);
    // Assign the new code to lhs and free temporary string
    lhs->code = result;
    free(st);
}
void conditional_handle(struct data* lhs, struct data rhs1, struct data rhs2,int* n, char*s)
{
    char *truel=newLabel();
    char *endl=newLabel();
    char *st = calloc(500, sizeof(char));
    sprintf(lhs->str, "t%d", *n);
    sprintf(st,"if(%s %s %s) goto %s\nt%d=FALSE \ngoto %s\n%s:\nt%d = TRUE \n%s:\n",
    rhs1.str,s,rhs2.str,truel,(*n),endl,truel,(*n),endl);
    (*n)++;
    int len1 = (rhs1.code != NULL) ? strlen(rhs1.code) : 0;
    int len2 = (rhs2.code != NULL) ? strlen(rhs2.code) : 0;
    char *result = calloc(len1 + len2+ strlen(st) + 1, sizeof(char));
    if (rhs1.code != NULL)
        strcat(result, rhs1.code);
    if (rhs2.code != NULL)
        strcat(result, rhs2.code);
    strcat(result, st);
    lhs->code = result;
    free(st);
}
void conditional_handle_not(struct data* lhs, struct data rhs1,int* n)
{
    char *truel=newLabel();
    char *endl=newLabel();
    char *st = calloc(500, sizeof(char));
    sprintf(lhs->str, "t%d", *n);
    sprintf(st,"if(!%s) goto %s\nt%d=FALSE \ngoto %s\n%s:\nt%d = TRUE \n%s:\n",
    rhs1.str,truel,(*n),endl,truel,(*n),endl);
    (*n)++;
    int len1 = (rhs1.code != NULL) ? strlen(rhs1.code) : 0;
    char *result = calloc(len1 + strlen(st) + 1, sizeof(char));
    if (rhs1.code != NULL)
        strcat(result, rhs1.code);
    strcat(result, st);
    lhs->code = result;
    free(st);
}
void handle_rec_st(struct data* lhs,struct data rhs1,struct data rhs2)
{
    int len1 = (rhs1.code != NULL) ? strlen(rhs1.code) : 0;
    int len2 = (rhs2.code != NULL) ? strlen(rhs2.code) : 0;
    char *result = calloc(len1 + len2+50, sizeof(char));
    if (rhs1.code != NULL)
        strcat(result, rhs1.code);
    if (rhs2.code != NULL)
        strcat(result, rhs2.code);
    lhs->code = result;
}
void conditional_if(struct data* lhs,struct data rhs1,struct data rhs2)
{
    int len1 = (rhs1.code != NULL) ? strlen(rhs1.code) : 0;
    int len2 = (rhs2.code != NULL) ? strlen(rhs2.code) : 0;
    char *endl=newLabel();
    char *st = calloc(200+len2, sizeof(char));
    sprintf(st,"if(!%s) goto %s\n%s%s:\n",
    rhs1.str,endl,rhs2.code,endl);   
    char *result = calloc(len1 + strlen(st) + 1, sizeof(char));
    if (rhs1.code != NULL)
        strcat(result, rhs1.code);
    strcat(result, st);
    lhs->code = result;
    free(st);
}
void conditional_if_else(struct data* lhs,struct data rhs1,struct data rhs2,struct data rhs3)
{
    int len1 = (rhs1.code != NULL) ? strlen(rhs1.code) : 0;
    int len2 = (rhs2.code != NULL) ? strlen(rhs2.code) : 0;
    int len3 = (rhs3.code != NULL) ? strlen(rhs3.code) : 0;
    char *truel=newLabel();
    char *endl=newLabel();
    char *st = calloc(200+len3+len2, sizeof(char));
    sprintf(st,"if(%s) goto %s\n%sgoto %s\n%s:\n%s%s:\n",
    rhs1.str,truel,rhs3.code,endl,truel,rhs2.code,endl);  
    char *result = calloc(len1 + strlen(st) + 1, sizeof(char));
    if (rhs1.code != NULL)
        strcat(result, rhs1.code);
    strcat(result, st);
    lhs->code = result;
    free(st);
}
void while_handler (struct data* lhs,struct data rhs1,struct data rhs2)
{
    int len1 = (rhs1.code != NULL) ? strlen(rhs1.code) : 0;
    int len2 = (rhs2.code != NULL) ? strlen(rhs2.code) : 0;
    char *beginl=newLabel();
    char *endl=newLabel();
    char *st = calloc(200+len2+len1, sizeof(char));
    if(len1!=0)
    sprintf(st,"%s:\n%sif(!%s) goto %s\n%sgoto %s\n%s:\n",
    beginl,rhs1.code,rhs1.str,endl,rhs2.code,beginl,endl);   
    else
    sprintf(st,"%s:\nif(!%s) goto %s\n%sgoto %s\n%s:\n",
    beginl,rhs1.str,endl,rhs2.code,beginl,endl);
    lhs->code = st;
}
void for_to(struct data* lhs,struct data rhs1,struct data rhs2,struct data rhs3,struct data rhs4)
{
    char *beginl=newLabel();
    char *endl=newLabel();
    int len1 = (rhs1.code != NULL) ? strlen(rhs1.code) : 0;
    int len2 = (rhs2.code != NULL) ? strlen(rhs2.code) : 0;
    int len3 = (rhs3.code != NULL) ? strlen(rhs3.code) : 0;
    int len4 = (rhs4.code != NULL) ? strlen(rhs4.code) : 0;
    char *result=calloc(200+len2+len1+len3, sizeof(char));
    if (rhs1.code != NULL)
        strcat(result, rhs1.code);
    if (rhs2.code != NULL)
        strcat(result, rhs2.code);
    if (rhs3.code != NULL)
        strcat(result, rhs3.code);
    char *st=calloc(200+len4, sizeof(char));
    sprintf(st,"%s=%s\n%s:\nif(%s>%s) goto %s\n%s%s++\ngoto %s\n%s:\n",
    rhs1.str,rhs2.str,beginl,rhs1.str,rhs3.str,endl,rhs4.code,rhs1.str,beginl,endl); 
    strcat(result,st);
    lhs->code=result;
    free(st);
}
void for_downto(struct data* lhs,struct data rhs1,struct data rhs2,struct data rhs3,struct data rhs4)
{
    char *beginl=newLabel();
    char *endl=newLabel();
    int len1 = (rhs1.code != NULL) ? strlen(rhs1.code) : 0;
    int len2 = (rhs2.code != NULL) ? strlen(rhs2.code) : 0;
    int len3 = (rhs3.code != NULL) ? strlen(rhs3.code) : 0;
    int len4 = (rhs4.code != NULL) ? strlen(rhs4.code) : 0;
    char *result=calloc(200+len2+len1+len3, sizeof(char));
    if (rhs1.code != NULL)
        strcat(result, rhs1.code);
    if (rhs2.code != NULL)
        strcat(result, rhs2.code);
    if (rhs3.code != NULL)
        strcat(result, rhs3.code);
    char *st=calloc(200+len4, sizeof(char));
    sprintf(st,"%s=%s\n%s:\nif(%s<%s) goto %s\n%s%s--\ngoto %s\n%s:\n",
    rhs1.str,rhs2.str,beginl,rhs1.str,rhs3.str,endl,rhs4.code,rhs1.str,beginl,endl); 
    strcat(result,st);
    lhs->code=result;
    free(st);
}
void read_handle(struct data* lhs,struct data rhs)
{
    int len= (rhs.code != NULL) ? strlen(rhs.code) : 0;
    char *st=calloc(500,sizeof(char));
    sprintf(st,"read(%s)\n",rhs.str);
    char *result=calloc(200+len,sizeof(char));
    if (rhs.code != NULL)
    strcat(result,rhs.code);
    strcat(result,st);
    lhs->code=result;
    free(st);
}