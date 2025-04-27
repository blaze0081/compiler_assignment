#ifndef AST_H
#define AST_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

typedef struct node{
    struct node* children[20]; //max 20 children for each node
    char name[30];
    int n; //keeps track of number of children node
    int ival; // integer value
    // float fval; //float value [not used in this part]
}Node;
extern Node * myhead;
void dfs(Node * head);
void addchild(Node * head,Node * child);
void setname(Node * head, char * str);
Node* createNode();
void initialize(Node * head);
void print_generalized(Node* head, int level);
#endif