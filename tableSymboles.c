#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "tableSymboles.h"



void addConst(char* idf,char* val){

  Const *elm=NULL;
  elm=(Const*)malloc(sizeof(Const));
  elm->nom=malloc(sizeof(char));
  elm->val=malloc(sizeof(char));
  strcpy(elm->nom,idf);
  strcpy(elm->val,val);
  elm->suivant=NULL;

  if(consts==NULL){
    consts=elm;
  }
  else{
    Const * nv=consts;
    while((nv->suivant)!=NULL){
      nv=(nv->suivant);
    }
    (nv->suivant)=elm;
  }

}




/*
//fontions symantiques
*/

//verfier si l'idf a était deja declaré
int declaredeja(char *idf){
  if(existe(idf)){
    yyerror("idf deja declare");
    return 1;
  }
    return 0;
}

//verifier si l'idf utilisé et declaré
int nondeclare(char *idf){
  if(!existe(idf)){
    yyerror("idf non declarer");
    return 0;
  }else{
    return 1;
  }
}
//savoir le type de l'idf
char* idfType(char* idf){
  Entite *newentite ;
  int ih = hashage(idf);
  newentite = TS[ih];
  //voir si l'idf existe dans la ts et retourner son type
  while(newentite != NULL){
      if (strcasecmp(idf, newentite->nom) == 0) return strdup(newentite->type);
      else newentite = newentite->suivant ;
  }
  //s'il existe pas ça veut dire que c'est une valeur INT ou FLT ou CHR
  int i=0;
  if(sscanf(idf,"%d",&i)){
    i=0;
    while(idf[i]!='\0'){
      if(isdigit(idf[i])) i++;
      else break;
    }
    if(i==strlen(idf))
      return "INT";
    else return "FLT";
  }else{
    return "CHR";
  }
  return NULL;
}

//comparer les types des idfs
void compareTypes(char* type1,char* type2){
  if( (strcasecmp(type1,type2)!=0) && !( (strcasecmp("FLT",type1)==0 && strcasecmp(type2,"INT")==0) )) yyerror(" types incompabtibles.");
}
//savoir la nature de l'idf
char* natureIdf(char* idf){
  Entite *newentite ;
  int ih = hashage(idf);
  newentite = TS[ih];
  while(newentite != NULL){
      if (strcasecmp(idf, newentite->nom) == 0) return strdup(newentite->nature) ;
      else newentite = newentite->suivant ;
  }
  return NULL;
}
//ne pas autoriser la modification d'une constante
void modifConstant(char* idf){
  if (strcasecmp("cons",natureIdf(idf)) == 0) yyerror(" on peut pas modifier une constante.");
}

//acces faux a la case du tableau
void accesTab(char* idf,int i){
  Entite *newentite ;

  int ih = hashage(idf);

  newentite = TS[ih];
  int taille;
  while(newentite != NULL){
      if (strcasecmp(idf, newentite->nom) == 0){ taille=(newentite->tailleTab); break;}
      else newentite = newentite->suivant ;
  }
  if(i>=taille || i<0) yyerror(" acces faux au tableau, case inexsitante.");
}


/*
//fontions de la ts
*/


void inserer(char *idf,char *newnature,char *newtype,int newsize){

      int ih;
      Entite *newentite = malloc(sizeof(Entite));
      newentite->nom = malloc(length+1);

      strcpy(newentite->nom,idf);
      newentite->type   = newtype ;
      newentite->nature = newnature ;
      newentite->tailleTab   = newsize ;

      ih = hashage(idf);

      if(TS[ih] == NULL){
      	TS[ih] = newentite;
  	    newentite->suivant = NULL;
      }
      else {
  	    newentite->suivant = TS[ih];
  	    TS[ih] = newentite;
      }

}


int existe(char *idf){

    Entite *newentite ;

    int ih = hashage(idf);

    newentite = TS[ih];

    while(newentite != NULL)
    {
        if (strcasecmp(idf, newentite->nom) == 0) return 1 ;
        else newentite = newentite->suivant ;
    }
    return 0;
}

// fonction de hashage
int hashage(char *idf){
    return toupper(idf[0]) % tailleTS ;
}

void afficher(){
    printf("    ************** La Table des Symboles ********************\n");
    printf("     _______________________________________________________ \n");
    printf("    |   idf       |   nature     |   type      |  size      |\n");

    int i ;

    Entite *newentite ;

    for ( i = 0; i < tailleTS; i++){

        newentite = TS[i] ;

        while(newentite != NULL) {
            printf("    |-------------|--------------|-------------|------------|\n");

            printf("    |%9s    |%7s       |",newentite->nom,newentite->nature);

            printf("  %5s      |%7d     | \n",newentite->type,newentite->tailleTab);

            newentite=newentite->suivant;
        }
    }
    printf("    *-------------------------------------------------------*\n");
}

//vider la ts des idfs
void viderTS(){
    Entite *entitesuivante,*entitep;
    int i;

    for (i = 0; i<tailleTS; i++){
        entitep = TS[i];
        while (entitep){
	        free(entitep->nom);
	        entitesuivante  = entitep->suivant;
	        free(entitep);
	        entitep = entitesuivante;
        }
        TS[i] = NULL;
    }
}
