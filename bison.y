%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "tableSymboles.h"
    #include "Quad.h"
    #include "Assembly.h"
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

  struct val{
    char* type;
    char* value;
  }val;

  struct jump{
    int sauvFin;
    int sauvDeb ;
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
%token FLOAT INTEGER IDF CHAR MC_INT MC_FLOAT MC_CHAR WHILE
%token '='
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

%type <NT> EXPRESSION
%type <val>VALEUR
%type <chaine>TYPE FLOAT INTEGER IDF CHAR VAR CONDITION
%type <jump>INST_IF

%left OR
%left AND
%left SUPP SUPEGALE EGALE NONEGALE INFEGALE INF
%left PLUS MOIN
%left MULTI DIV
%left PUISSANCE
%left DIFF
%left PARENTHESEOUVERT

%start DEBUT

%%

DEBUT: DECLARATION INSTRUCTION
;
DECLARATION : DEC | DEC_AFF | DECLARATION DEC | DECLARATION DEC_AFF
;

DEC: TYPE IDF NOUVELLE_LIGNE
              {
                if(!declaredeja($2)){
                  inserer($2,"var",$1,1);
                }
              }
;
DEC_AFF :  TYPE IDF '=' VALEUR NOUVELLE_LIGNE
             {
                if(!declaredeja($2)){
                  inserer($2,"var",$1,1);
                }
              }
;
INSTRUCTION : INSTRUCTION INST | INST
;

INST : AFFECTATION | INST_IF;

AFFECTATION: IDF '=' EXPRESSION NOUVELLE_LIGNE
                 {
                  if( declared($1) )
                  {
                    compareTypes(idfType($1),$3.type);
                    addQuad(":=",$3.temp," ",$1);
                  }
                 }
;

EXPRESSION: EXPRESSION PLUS EXPRESSION{
              compareTypes($1.type,$3.type);
              $$.temp=whatT();
              $$.type=$1.type;
              addQuad("+",$1.temp,$3.temp,$$.temp);
            }
            | EXPRESSION MOIN EXPRESSION{
              compareTypes($1.type,$3.type);
              $$.temp=whatT();
              $$.type=$1.type;
              addQuad("-",$1.temp,$3.temp,$$.temp);
            }
            | EXPRESSION DIV EXPRESSION{
              if(atoi($3.temp)==0 && strcmp(idfType($3.temp),"INT")==0)
                yyerror("devision par zero");
              else
                compareTypes($1.type,$3.type);
              $$.temp=whatT();
              $$.type=$1.type;
              addQuad("/",$1.temp,$3.temp,$$.temp);
            }
            | EXPRESSION PUISSANCE EXPRESSION{
              compareTypes($1.type,$3.type);
              $$.temp=whatT();
              $$.type=$1.type;
              addQuad("^",$1.temp,$3.temp,$$.temp);
            }
            | EXPRESSION MULTI EXPRESSION{
              compareTypes($1.type,$3.type);
              $$.temp=whatT();
              $$.type=$1.type;
              addQuad("*",$1.temp,$3.temp,$$.temp);
            }
            |  PARENTHESEOUVERT EXPRESSION PARENTHESEFERME {
              $$.temp=$2.temp;
              $$.type=$2.type;
            }
            |  VAR {
              $$.temp=$1;
              $$.type=idfType($1);
            }
            | VALEUR{
              $$.temp=$1.value;
              $$.type=$1.type;
            }
            ;

VALEUR: FLOAT { $$.type = "FLT"; $$.value = $1;}
        | INTEGER {$$.type = "INT"; $$.value = $1;}
        | CHAR {$$.type = "CHR"; $$.value = $1;}
        ;
VAR: IDF;

TYPE: MC_INT { $$ = "INT"}
      | MC_CHAR { $$ = "CHR" }
      | MC_FLOAT { $$ = "FLT" }
      ;

INST_IF: IF PARENTHESEOUVERT CONDITION PARENTHESEFERME DEUXPOINTS NOUVELLE_LIGNE INSTRUCTION NOUVELLE_LIGNE SUITE_IF{
                                                                                                                                $$.sauvDeb = nquad ;
                                                                                                                                addQuad("BZ","",$3,"");
                                                                                                                               }

 ;
SUITE_IF: ELSE NOUVELLE_LIGNE INST
          |ELIF PARENTHESEOUVERT CONDITION PARENTHESEFERME DEUXPOINTS NOUVELLE_LIGNE INSTRUCTION NOUVELLE_LIGNE SUITE_IF
          |;

CONDITION:   EXPRESSION SUPP EXPRESSION{
              $$ = addQuadComp("BP",$1.temp,$3.temp);
             }
             | EXPRESSION INF EXPRESSION{
               $$ = addQuadComp("BM",$1.temp,$3.temp);
             }
             | EXPRESSION EGALE EXPRESSION{
               $$ = addQuadComp("BZ",$1.temp,$3.temp);
             }
             | EXPRESSION NONEGALE EXPRESSION{
               $$ = addQuadComp("BNZ",$1.temp,$3.temp);
             }
             | EXPRESSION SUPEGALE EXPRESSION{
               $$ = addQuadComp("BPZ",$1.temp,$3.temp);
             }
             | EXPRESSION INFEGALE EXPRESSION{
               $$ = addQuadComp("BMZ",$1.temp,$3.temp);
             }
             | EXPRESSION OR EXPRESSION{
               $$ = whatT();
               addQuadLogi(1,$1.temp,$3.temp,$$);
             }
             | EXPRESSION AND EXPRESSION{
               $$ = whatT();
               addQuadLogi(2,$1.temp,$3.temp,$$);
             }
             | DIFF EXPRESSION{
               $$ = whatT();
               addQuadLogi(3,$2.temp,"",$$);
             }
             ;

%%



int yyerror (char* msg){
	printf("Erreur a la ligne: %d, colonne: %d, %s\n",yylineno,colonne,msg);
  return 1;
}

int main(){
  yyin=fopen("input.txt","r");
  yyparse();
  afficher();
  saveQuads();
  generate_Assembly_code();
  viderTS();
  return 0;
}
