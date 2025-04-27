#include "ast.h"
Node * myhead;

void dfs_tree(Node * head ,FILE * fp)
{
    if(head==NULL)
    return;
    fputs("[",fp);
    fputs(head->name,fp);
    for(int i=0; i< head->n; i++)
    {
        dfs_tree(head->children[i],fp);
    }
    fputs("]",fp);
}
void dfs(Node * head)
{
    FILE *fp;
    fp = fopen("tree.txt", "w");

    dfs_tree(head,fp);
    fclose(fp);
}
void initialize(Node * head)
{
    head->n=0;
    for(int i=0; i<20; i++)
    head->children[i]=NULL;
    memset(head->name,0,30);
}
Node* createNode()
{
    Node * head= calloc(1,sizeof(Node));
    initialize(head);
    return head;
}
void addchild(Node * head,Node * child)
{
    head->children[head->n]=child;
    head->n++;
}
void setname(Node * head, char * str)
{
    strcpy(head->name,str);
}
void print_generalized(Node* head, int level) {
    if (head == NULL) return;

    for (int i = 0; i < level; i++) printf("  "); // indent
    printf("(");
    printf("%s", head->name);

    if (head->n == 0) {
        printf(")\n");
        return;
    }

    printf("\n");
    for (int i = 0; i < head->n; i++) {
        print_generalized(head->children[i], level + 1);
    }

    for (int i = 0; i < level; i++) printf("  ");
    printf(")\n");
}

