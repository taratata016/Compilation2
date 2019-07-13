
FILE *assembly_file;
int save_etiq[1000];
int etiq_index=0;


//fonction qui retourne la valeur d'une certaine constante
char* getConstVal(char* cons){
  int index=0;
  Const* p;

  for(p=consts;p!=NULL;p=p->suivant){
    if(strcmp(p->nom,cons)==0){
      return strdup(p->val);
    }
  }
  return "?";
}

/*
* DECLARATION
*/

void declaration(Entite* table,int i){
  Entite *p;

  for(p=table;p!=NULL;p=p->suivant){

    if(!strcmp(p->nature,"var") && !strcmp(p->type,"INT") ) fprintf(assembly_file ,"	%s DD  ? \n",p->nom);

    if(!strcmp(p->nature,"var") && !strcmp(p->type,"FLT") ) fprintf(assembly_file ,"	%s DQ  ? \n",p->nom);

    if(!strcmp(p->nature,"var") && !strcmp(p->type,"CHR") ) fprintf(assembly_file ,"	%s DB  ? \n",p->nom);

    char * valConst= getConstVal( p->nom );

    if(!strcmp(p->nature,"cons") && !strcmp(p->type,"INT") ) fprintf(assembly_file ,"	%s DD  %s \n",p->nom,valConst);

    if(!strcmp(p->nature,"cons") && !strcmp(p->type,"FLT") ) fprintf(assembly_file ,"	%s DQ  %s \n",p->nom,valConst);

    if(!strcmp(p->nature,"cons") && !strcmp(p->type,"CHR") ) fprintf(assembly_file ,"	%s DB  %s \n",p->nom,valConst);

    if(!strcmp(p->nature,"tab") && !strcmp(p->type,"INT") ) fprintf(assembly_file ,"	%s DD %d DUP  ? \n",p->nom, (p->tailleTab)/4);

    if(!strcmp(p->nature,"tab") && !strcmp(p->type,"FLT") ) fprintf(assembly_file ,"	%s DQ %d DUP  ? \n",p->nom, (p->tailleTab)/4);

    if(!strcmp(p->nature,"tab") && !strcmp(p->type,"CHR") ) fprintf(assembly_file ,"	%s DB %d DUP  ? \n",p->nom, (p->tailleTab)/4);

  }
}


void generate_delcaration(Entite **table){

  int i;

  char* title=malloc(sizeof(char));
  Entite *p;

  //recuperer le nom du programme
  for(i=0;i<tailleTS;i++){
      if(table[i] != NULL){
         for(p=table[i];p!=NULL;p=p->suivant){
           if(strcmp(p->nature,"PROG")==0){
             strcpy(title,p->nom);
           }
         }
      }
  }

  fprintf(assembly_file ,"TITLE %s.asm : %s\n\n","Mini python","Mini python");

  fprintf(assembly_file ,"Pile SEGMENT STACK\n\tDW 100 dup(?)\nPile ENDS\n\n");


  fprintf(assembly_file ,"DONNEE SEGMENT  \n");
  //appeler la fonction qui fait la declaration pour chaque list de la table de hashage
  for(i=0;i<tailleTS;i++){
      if(table[i] != NULL){
         declaration(table[i],i);
      }
  }
  fprintf(assembly_file ,"DONNEE ENDS  \n\n");
}

/*
* INSTRUCTIONS
*/
void generate_instruction(){

	fprintf(assembly_file ,"CODE SEGMENT\n");
  fprintf(assembly_file ,"MAIN:\n");
	fprintf(assembly_file ,"		ASSUME CS:CODE,		DS:DONNEE,		SS:Pile\n		MOV AX,Pile\n		MOV SS, AX\n\n");

  int saveEtiqs[1000];
  int nbEtiqs=0;
	int index ;

  //sauvegarder les etiqs qu'on a dans un tableau
  for (index = 0; index < nquad; ++index){
    if(quadruplet[index].op[0]=='B' && quadruplet[index].op[1]!='O'){
      saveEtiqs[nbEtiqs]= atoi(quadruplet[index].operande1) ;
      //printf("etiq %s %d %d\n",quadruplet[index].op,nbEtiqs, atoi(quadruplet[index].operande1) );
      nbEtiqs++;
    }
  }

	char* operation = malloc(sizeof(char*)) ;

	for (index = 0; index < nquad; ++index){ // la grande boucle pour generer le code assembleur depuis les quadruplets

    //verifier a chaque fois si on a un jump vers le quadruplet qu'on trete
    int ii=0;
    for(ii=0;ii<nbEtiqs;ii++){
      if(saveEtiqs[ii]==index){
        fprintf(assembly_file, "etiq_%d :\n", saveEtiqs[ii]);
        saveEtiqs[ii]=-1;
        break;
      }
    }

    /*
    * Traitement des quads avec les operations arethmitiques
    */
		if ((quadruplet[index].op[0]=='+') || (quadruplet[index].op[0]=='-') || (quadruplet[index].op[0]=='/') || (quadruplet[index].op[0]=='*') ){
  			switch (quadruplet[index].op[0]){
  				case '+' : 	strcpy(operation,"ADD");break ;
  				case '*' : 	strcpy(operation,"MUL");break ;
  				case '/' :	strcpy(operation,"DIV");break ;
  			  case '-' :  strcpy(operation,"SUB");break ;
  			}
  			if ((quadruplet[index].operande1[0]=='T') && (quadruplet[index].operande2[0]=='T')){
  				fprintf(assembly_file,"		POP AX \n");
  				fprintf(assembly_file,"		POP BX \n");
  				fprintf(assembly_file,"		%s AX,BX \n",operation);
  				fprintf(assembly_file,"		PUSH AX\n");
  			}
  			else if (quadruplet[index].operande1[0]=='T'){
					fprintf(assembly_file,"		POP AX \n");
					fprintf(assembly_file,"		%s AX,%s \n",operation, quadruplet[index].operande2);
					fprintf(assembly_file,"		PUSH AX\n");
  			}
  			else if (quadruplet[index].operande2[0]=='T'){
					fprintf(assembly_file,"		POP AX \n");
					fprintf(assembly_file,"		%s AX,%s \n",operation, quadruplet[index].operande1);
					fprintf(assembly_file,"		PUSH AX\n");
				}else{
					fprintf(assembly_file,"		MOV AX,%s \n",quadruplet[index].operande1);
					fprintf(assembly_file,"		%s AX,%s \n",operation, quadruplet[index].operande2);
					fprintf(assembly_file,"		PUSH AX\n");
				}
		}

    else if ((quadruplet[index].op[0]=='^')){
      if ((quadruplet[index].operande1[0]=='T') && (quadruplet[index].operande2[0]=='T')){
        fprintf(assembly_file,"		POP AX \n");
        fprintf(assembly_file,"		POP BX \n");
        fprintf(assembly_file,"		MOV CX,BX \n");
        fprintf(assembly_file,"		MOV BX,AX \n");
        fprintf(assembly_file,"label:\n MUL AX,BX \n");
        fprintf(assembly_file,"		loop label\n");
        fprintf(assembly_file,"		PUSH AX\n");
      }
      else if (quadruplet[index].operande1[0]=='T'){
        fprintf(assembly_file,"		POP AX \n");
        fprintf(assembly_file,"		MOV CX,%s \n",quadruplet[index].operande2);
        fprintf(assembly_file,"		MOV BX,AX \n");
        fprintf(assembly_file,"label:\n		MUL AX,BX \n");
        fprintf(assembly_file,"		loop label\n");
        fprintf(assembly_file,"		PUSH AX\n");
      }
      else if (quadruplet[index].operande2[0]=='T'){
        fprintf(assembly_file,"		POP AX \n");
        fprintf(assembly_file,"		MOV CX,AX \n");
        fprintf(assembly_file,"		MOV AX,%s \n",quadruplet[index].operande1);
        fprintf(assembly_file,"label:\n		MUL AX,%s \n",quadruplet[index].operande1);
        fprintf(assembly_file,"		loop label\n");
        fprintf(assembly_file,"		PUSH AX\n");
      }else{
        fprintf(assembly_file,"		MOV CX,%s \n",quadruplet[index].operande2);
        fprintf(assembly_file,"		MOV AX,%s \n",quadruplet[index].operande1);
        fprintf(assembly_file,"label:\n		MUL AX,%s \n",quadruplet[index].operande1);
        fprintf(assembly_file,"		loop label\n");
        fprintf(assembly_file,"		PUSH AX\n");
      }
    }

     /**
		 *	Traitement des quads avec les jumps (BZ, BNZ, BP, BPZ, BM, BMZ ou BR) ou l'affectation ":="
		 */

		else if (quadruplet[index].op[0] == ':'){ //affectation

        if (quadruplet[index].operande1[0]=='T'){
					fprintf(assembly_file,"		POP AX \n");
					fprintf(assembly_file,"		MOV %s, AX\n",quadruplet[index].resultat);
				}
				else if (quadruplet[index].resultat[0]=='T'){
						fprintf(assembly_file,"		MOV AX, %s \n",quadruplet[index].operande1);
						fprintf(assembly_file,"		PUSH AX\n");
				}
				else{
					fprintf(assembly_file,"		MOV AX, %s \n",quadruplet[index].operande1);
					fprintf(assembly_file,"		MOV %s, AX \n",quadruplet[index].resultat);
				}
			}

			else if ((quadruplet[index].op[0] == 'B') && ((quadruplet[index].op[1] != 'O'))){
				switch (quadruplet[index].op[1]){
					case 'Z' : 	strcpy(operation,"JE");break ;
					case 'N' :  strcpy(operation,"JNE");break ;
					case 'M' : 	if(quadruplet[index].op[2] == 'Z')
                        strcpy(operation,"JLE");
                      else
                        strcpy(operation,"JL");
                      break ;
					case 'P' :	if(quadruplet[index].op[2] == 'Z')
                        strcpy(operation,"JGE");
                      else
                        strcpy(operation,"JG");
                      break ;
					default: break;
				}
				if (quadruplet[index].op[1] != 'R'){ //Si le jump est conditionel

          if(quadruplet[index].operande2[0]=='T')
            fprintf(assembly_file,"		POP AX \n");
          else
            fprintf(assembly_file,"		MOV AX, %s \n",quadruplet[index].operande2);
          fprintf(assembly_file,"		CMP AX, 0 \n");
					fprintf(assembly_file,"		%s etiq_%s \n",operation,quadruplet[index].operande1);
				}
				else{ //Sinon le jump est inconditionel (BR)
					fprintf(assembly_file,"		JMP etiq_%s \n",quadruplet[index].operande1) ;
				}
			}

      //si on a un jump vers la fin dans les quadruplets on insere son etiq
      for(ii=0;ii<nbEtiqs;ii++){
        if(saveEtiqs[ii]==index+1 && index+1==nquad){
          fprintf(assembly_file, "etiq_%d :\n",saveEtiqs[ii]) ;
          break;
        }
      }
	}
  //the end
	fprintf(assembly_file,"		\n\nMOV AH, 4Ch\nINT 21h ; MAIN ENDS\n");
	fprintf(assembly_file ,"MAIN ENDS\nCODE ENDS\n");

}


void generate_Assembly_code(){
    assembly_file = fopen("Assembly.txt","w");
  //  find_etiq() ;				// find all jump etiq and save theme in a table
//  	sort(save_etiq,etiq_index); // to save all etiq before writing assembly code
     generate_delcaration(TS);
     generate_instruction();
}
