%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "tableSymboles.h"

    extern FILE* yyin ;
    extern int yylineno;
    extern int colonne;

%}

%union
{
  char* chaine;

  struct NT{
    char* type;
    char* temp;
  }NT;

  struct jump{
    int sauvFin;
    int sauvDeb;
  }jump;

}

%token POINTVIRGULE DEUXPOINTS PARENTHESEOUVERT PARENTHESEFERME CROCHETOUVERT CROCHETFERME VIRGULE
%token PROGRAM Begin END CONSTANT
%token IN_RANGE
%token NOUVELLE_LIGNE
%token TAB
%token IF ELSE ELIF ENDIF
%token CASE CHECK SO ENDCHECK DEFAULT ENDCASE
%token FOR DO ENDFOR
%token COMMENTAIRE
%token <chaine>FLOAT <chaine>INTEGER <chaine>IDF CHAR MC_INT MC_FLOAT MC_CHAR WHILE
%token AFFECTATION
%token PLUS
%token MULTI
%token DIV
%token PUISSANCE
%token MOIN
%token AND
%token OR
%token DIFF
%token SUPP
%token INF
%token EGALE
%token NONEGALE
%token SUPEGALE
%token INFEGALE

%left OR
%left AND
%left SUPP SUPEGALE EGALE NONEGALE INFEGALE INF
%left PLUS MOIN
%left MULTI DIV
%left PUISSANCE
%left DIFF
%left PARENTHESEOUVERT

%start ENTRY_POINT

%%
ENTRY_POINT: PARENTHESEOUVERT ;
%%

int yyerror (char* msg){
	printf("Erreur a la ligne: %d, colonne: %d, %s\n",yylineno,colonne,msg);
	return 1;
}

int main(){
  yyin=fopen("input.txt","r");
  yyparse();
  afficher();

  viderTS();
  return 0;
}
