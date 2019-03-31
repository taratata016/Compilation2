%{
  #define _GNU_SOURCE
    #include <stdio.h>
    #include <stdlib.h>
    #include "tableSymboles.h"
    #include "Quad.h"
    #include "Assembly.h"

    extern FILE* yyin ;
    extern int yylineno;
    extern int colonne;

    char *sauvType;
    char *sauvVal;
    int nbChecks=0;
    int nbChecks2=0;

    //pour sauvegrader les idfs
    typedef struct id
    {
      char nom[9];
      struct id * svt;
    } id;

    id*  idfs;

    // ajouter un idfs dans la liste ids
    void ajouterid(char *idf){

      id *elm=NULL;
      elm=(id*)malloc(sizeof(id));
      strcpy(elm->nom,idf);
      elm->svt=NULL;

      if(idfs==NULL){
        idfs=elm;
      }
      else{
        id * nv=idfs;
        while((nv->svt)!=NULL){
          nv=(nv->svt);
        }
        (nv->svt)=elm;
      }
    }

    //inserer les idfs dans la table des symboles
    void insereridfs(char *ch,int n){
      id * nv=idfs;
       while(nv!=NULL){
          if(!declaredeja(nv->nom)){
            inserer(nv->nom,"var",ch,n);
          }
          nv=(nv->svt);
      }
    }


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
%token <chaine>FLOAT <chaine>INTEGER <chaine>IDF CHAR INT FLT CHR
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


%type <NT>EXPRESSION
%type <chaine>CONDITION IDFTAB VAR VALEUR
%type <jump>PREMIERIF DEUXIEMIF INST_BOUCLE SECOND_FOR FIRST_FOR


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
DEBUT: PROGRAM IDF{inserer($2,"PROG","NAME",1);} ListeDeclarations Begin Instruction END IDF {printf("\nCode Correct.\n");}
;

ListeDeclarations: ListeDeclarations Declaration
                   |
                   ;

Declaration: IDF DeclarationVar DEUXPOINTS TYPE POINTVIRGULE {
                ajouterid($1);
				        insereridfs(sauvType,1);
                idfs=NULL;
             }
             | CONSTANT IDF AFFECTATION VALEUR POINTVIRGULE {
                if(!declaredeja($2)){
                  inserer($2,"cons",sauvType,1);
                  //sauver la valeur de la constante pour le code assembleur dans un tableau
                  addConst($2,$4);
                  //addQuad(":=",$<chaine>4,"",$2);
                }
             }
             | IDF CROCHETOUVERT INTEGER CROCHETFERME DEUXPOINTS TYPE POINTVIRGULE
               { if(!declaredeja($1)){
                  inserer($1,"tab",sauvType,atoi($3));
                  addQuad("BOUNDS","0",$3,"");
                  addQuad("ADEC",$1," "," ");
               }

               };

DeclarationVar: VIRGULE IDF DeclarationVar
                {
				         ajouterid($2);
                }
                |
                ;

TYPE: INT { sauvType = strdup($1);}
      | CHR { sauvType = strdup($1); }
      | FLT { sauvType = strdup($1); }
      ;

VAR: IDF {
      nondeclare($1);
     }
     | IDFTAB
     ;

IDFTAB: IDF CROCHETOUVERT INTEGER CROCHETFERME{
          nondeclare($1);
          accesTab($<chaine>1,atoi($3));
          char* c = $1;
        	c = strcat(c,"[");
        	c = strcat(c,$3);
        	c = strcat(c,"]");
          $$ = c;
        };

VALEUR: FLOAT {sauvType = "FLT";}
        | INTEGER {sauvType = "INT";}
        | CHAR {sauvType = "CHR";}
        ;

Instruction : INST_AFFECTATION POINTVIRGULE Instruction
              | INST_IF Instruction
              | INST_BOUCLE Instruction
              | INST_SWITCH Instruction
              | COMMENTAIRE Instruction
              |
              ;

INST_AFFECTATION: VAR AFFECTATION EXPRESSION {
                    modifConstant($1);
                    compareTypes(idfType($1),$3.type);
                    addQuad(":=",$3.temp," ",$<chaine>1);
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
              $$.temp=$1;
              $$.type=sauvType;
            }
            ;

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
             | EXPRESSION OU EXPRESSION{
               $$ = whatT();
               addQuadLogi(1,$1.temp,$3.temp,$$);
             }
             | EXPRESSION ET EXPRESSION{
               $$ = whatT();
               addQuadLogi(2,$1.temp,$3.temp,$$);
             }
             | DIFF EXPRESSION{
               $$ = whatT();
               addQuadLogi(3,$2.temp,"",$$);
             }
             ;


INST_BOUCLE: SECOND_FOR POINTVIRGULE INST_AFFECTATION PARENTHESEFERME DO Instruction ENDFOR{
              addQuad("BR",intToStr($1.sauvDeb),"","");
              strcpy(quadruplet[$1.sauvFin].operande1,intToStr(nquad)) ;
            };
SECOND_FOR: FIRST_FOR PARENTHESEOUVERT INST_AFFECTATION POINTVIRGULE CONDITION{
              $$.sauvFin = nquad ;
              addQuad("BNZ","",$5,"");
            };
FIRST_FOR: FOR{
       $$.sauvDeb = nquad;
      };



INST_IF: PREMIERIF Instruction ENDIF{
           strcpy(quadruplet[$1.sauvFin].operande1 , intToStr(nquad)) ;
         }
         | DEUXIEMIF Instruction ENDIF{
           strcpy(quadruplet[$1.sauvDeb].operande1 , intToStr(nquad)) ;
         }
         ;

PREMIERIF: DEUXIEMIF Instruction ELSE{
            $$.sauvFin = nquad ;
            addQuad("BR","","","");
            strcpy(quadruplet[$1.sauvDeb].operande1 , intToStr(nquad) );
           }
           ;

DEUXIEMIF: IF PARENTHESEOUVERT CONDITION PARENTHESEFERME THEN{
            $$.sauvDeb = nquad ;
            addQuad("BZ","",$3,"");
           }
           ;



INST_SWITCH:  CASE PARENTHESEOUVERT VAR PARENTHESEFERME CHECKS ENDCASE{
              //mettre a jour les jumps des BR des CHECKS precedents
              while(nbChecks2>0){
                strcpy(quadruplet[atoi(depiler(&pile2))].operande1 , intToStr(nquad) );
                nbChecks2--;
              }
             };

CHECKS:  ONE_CHECK CHECKS;
        | DEFAULT{
          //on est arrivé au default => mettre a jour les jumps des BZ des CHECKS precedents
          while(nbChecks>0){
            strcpy(quadruplet[ atoi(depiler(&pile)) ].operande1 , intToStr(nquad) );
            nbChecks--;
          }
        } Instruction;

        |
        ;
ONE_CHECK: CHECK PARENTHESEOUVERT CONDITION PARENTHESEFERME SO{
            empiler(&pile,intToStr(nquad));
            addQuad("BZ","",$3,"");
            nbChecks++;
          } Instruction ENDCHECK{
            empiler(&pile2,intToStr(nquad));
            addQuad("BR","","","");
            nbChecks2++;
          };

%%

int yyerror (char* msg){
	printf("Erreur a la ligne: %d, colonne: %d, %s\n",yylineno,colonne,msg);
	return 1;
}

int main(){
  yyin=fopen("input.txt","r");
  yyparse();
  afficher();
  //simplfyMulti();
  //suppAffNutil();
  saveQuads();
  generate_Assembly_code();

  viderTS();
  return 0;
}
