#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "Quad.h"


void empiler(Pile **p,char *donne){
	Pile *new;

	new=(Pile*)malloc(sizeof(Pile));
	new->donnee=strdup(donne);

	new->prc=*p;
	*p=new;
}

char* depiler(Pile**p){
	char *res;
	Pile *H;
	H=*p;
	res=strdup(H->donnee);
	*p=H->prc;
	free(H);
	return res;
}

void addQuad(char* newop,char* newoperande1,char* newoperande2,char* newresultat){
	quadruplet[nquad].op		=	malloc(sizeof(char*));
	quadruplet[nquad].operande1 =	malloc(sizeof(char*));
	quadruplet[nquad].operande2 =	malloc(sizeof(char*));
	quadruplet[nquad].resultat =	malloc(sizeof(char*));

	strcpy(quadruplet[nquad].op,newop);
	strcpy(quadruplet[nquad].operande1,newoperande1);
	strcpy(quadruplet[nquad].operande2,newoperande2);
	strcpy(quadruplet[nquad].resultat,newresultat);
	nquad++;
}

void saveQuads(){
	int j;
	FILE* yyout_quadruple=NULL;
	yyout_quadruple=fopen("quadruplet.txt","w");

	fprintf(yyout_quadruple,"::::::::::: LA LISTE DES QUADRUPLETS :::::::::::::\n");

	    if (yyout_quadruple!=NULL)
	    {
	    	for (j=0;j<nquad;j++)
	        {
			    fprintf(yyout_quadruple,"%d - ( %s  ,  %s  ,  %s  ,  %s )\n",j, quadruplet[j].op,quadruplet[j].operande1,quadruplet[j].operande2, quadruplet[j].resultat);
		    }
		    fprintf(yyout_quadruple, "%d -\n", j);
		    fclose(yyout_quadruple);
	    }
	    else
	    {
	    	printf("Impossible d'ouvrir le fichier quadruplet.txt");
	    }

}

void addQuadLogi( int op, char* op1, char* op2, char* res){
	switch (op)	{
		// OU
		case 1:		addQuad("BNZ",intToStr(nquad+4),op1," ");
					addQuad("BNZ",intToStr(nquad+3),op2," ");
					addQuad(":=",intToStr(0)," ",res);
					addQuad("BR",intToStr(nquad+2)," "," ");
					addQuad(":=",intToStr(1)," ",res);break ;
		// ET
		case 2:		addQuad("BZ",intToStr(nquad+4),op1," ");
					addQuad("BZ",intToStr(nquad+3),op2," ");
					addQuad(":=",intToStr(1)," ",res);
					addQuad("BR",intToStr(nquad+2)," "," ");
					addQuad(":=",intToStr(0)," ",res);break ;
		// NOT (!exp)
		case 3:		addQuad("BZ",intToStr(nquad+3),op1," ");
					addQuad(":=",intToStr(0)," ",res);
					addQuad("BR",intToStr(nquad+2)," "," ");
					addQuad(":=",intToStr(1)," ",res);break;
	}
}

char* addQuadComp(char* booleen, char* op1, char* op2){
	char* tmp = whatT();
	addQuad("-",op1,op2,tmp);
	addQuad(booleen,intToStr(nquad+3),tmp," ");
	tmp = whatT();
	addQuad(":=",intToStr(0)," ",tmp);
	addQuad("BR",intToStr(nquad+2)," "," ");
	addQuad(":=",intToStr(1)," ",tmp);

	return tmp ;
}

char* intToStr(int number){
	char* num = malloc(sizeof(char*));
	sprintf(num, "%d", number);
	return num ;
}

char* whatT(){
	char* T =malloc(sizeof(char*));
	sprintf(T,"T%d",++cpt);
	return T ;
}


/*
*OPTIMISATION
*/


void simplfyMulti(){
	int i;

	for(i=0;i<nquad;i++){
			if(strcmp(quadruplet[i].op,"*")==0  ){
				if(strcmp(quadruplet[i].operande1,"2")==0){
					strcpy(quadruplet[i].op,"+");
					strcpy(quadruplet[i].operande1,quadruplet[i].operande2);
				}
				if(strcmp(quadruplet[i].operande2,"2")==0){
				    strcpy(quadruplet[i].op,"+");
					strcpy(quadruplet[i].operande2,quadruplet[i].operande1);
				}
			}
			if(strcmp(quadruplet[i].op,"^")==0){
				if(strcmp(quadruplet[i].operande1,"2")==0){
					strcpy(quadruplet[i].op,"*");
					strcpy(quadruplet[i].operande1,quadruplet[i].operande2);
				}
			}
	}
}


int utiliser(int i,int j,char * temp){
	int besoin=0;
	while((j<nquad)&&(besoin==0)){
			 if((strcmp(quadruplet[j].operande1,temp)==0) || (strcmp(quadruplet[j].operande2,temp)==0))
				 besoin=1;
			 if(((strcmp(quadruplet[j].op,"BR")==0)&&(atoi(quadruplet[j].operande1)<i)))
				 besoin=1;
			 if(((strcmp(quadruplet[j].op,"BZ")==0)&&(atoi(quadruplet[j].operande1)<i)))
				 besoin=1;
			 if(((strcmp(quadruplet[j].op,"BNZ")==0)&&(atoi(quadruplet[j].operande1)<i)))
				 besoin=1;
			 if(((strcmp(quadruplet[j].op,"BG")==0)&&(atoi(quadruplet[j].operande1)<i)))
				 besoin=1;
			 if(((strcmp(quadruplet[j].op,"BGE")==0)&&(atoi(quadruplet[j].operande1)<i)))
				 besoin=1;
			 if(((strcmp(quadruplet[j].op,"BL")==0)&&(atoi(quadruplet[j].operande1)<i)))
				 besoin=1;
			 if(((strcmp(quadruplet[j].op,"BLE")==0)&&(atoi(quadruplet[j].operande1)<i)))
				 besoin=1;
			 j++;
		 }
		 return besoin;
}

// sup toutes affectation non utilisée
void suppAffNutil(){
 int i,j,used,fini,p;
 char *temp;
 for(i=0;i<nquad;i++){
		 if(strcmp(quadruplet[i].op,":=")==0){
			 j=i+1;
			  //j permet de voir si on va utiliser le resultat de la'affectation dans les prochains quadruplets
			 temp = strdup(quadruplet[i].resultat);
			 used=utiliser(i,j,temp);
			 if( used == 0 ){ //si le resultat n'a pas été utilisé donc on supprime le quad
				 fini=0;
				 //p permet de revenir en arriere pour ecraser les quads non utils
				 p=i;
				 while( (p>0) && (fini==0) ){
					 if( (strcmp(quadruplet[p-1].op,"+")==0) || (strcmp(quadruplet[p-1].op,"-")==0) || (strcmp(quadruplet[p-1].op,"*")==0) || (strcmp(quadruplet[p-1].op,"/")==0)){
						 p--;
					 }
					 else{
					 	fini=1;
					 }
				 }
				 for(j=p;j<nquad-1;j++){
					 quadruplet[j]=quadruplet[j+(i-p)+1];
				 }
				 nquad=nquad-(i-p)-1;
			 }
		 }
 }
}
