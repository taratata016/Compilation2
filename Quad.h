// la structure d'un quadruplet
typedef struct Quadruplet Quadruplet;
struct Quadruplet{
    char* op;
    char* operande1;
    char* operande2;
    char* resultat;
};

//structure de donnée pour la pile
typedef struct Pile Pile;
struct Pile{
	char *donnee;
	struct Pile *prc;
};

Quadruplet quadruplet[1000];

Pile *pile;
Pile *pile2;
int nquad;
int cpt;


void empiler(Pile **p,char *donne);

char* depiler(Pile**p);

	// add new quardruplet
void addQuad(char* newop,char* newoperande1,char* newoperande2,char* newresultat);


	// enregistré les quadruplet dans un fichier text
void saveQuads() ;

	//	fonction pour créer la chaine de char des memoires de manoeuvres
char* whatT();

// add logical quadruplet
void addQuadLogi( int op, char* op1, char* op2, char* res);

// add comarative quadruplet
char* addQuadComp(char* booleen, char* op1, char* op2);

// convert num to char
char* intToStr(int num);

/*
*OPTIMISATION
*/

int utiliser(int i,int j,char * temp);
void suppAffNutil();
void simplfyMulti();
