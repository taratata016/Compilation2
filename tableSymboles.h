
#define tailleTS 79
#define length 7

//structure d'une case de la table des symboles
typedef struct Entite Entite;
struct Entite {
  char* nom; //nom de la variable ou la constante exp: a1,tab,etc
  char* nature; //variable ou constante
  char* type; //type
  int tailleTab;
  Entite *suivant;
};

//structure qui permet de sauver les valeurs des constantes
typedef struct Const Const;
struct Const {
  char* nom; //nom de la variable ou la constante exp: a1,tab,etc
  char* val; //variable ou constante
  Const *suivant;
};

void addConst(char* idf,char* val);

//la table des symboles
Entite *TS[tailleTS];
Const *consts;

//fonctions de la ts
int hashage(char *idf);
int existe(char *idf);
void inserer(char *idf,char *newnature,char *newtype,int newsize);
void afficher();
void viderTS();

//fonctions symantiques
int declaredeja(char *idf);
int declared(char *idf);
char* idfType(char* idf);
void compareTypes(char* idf1,char* idf2);
void modifConstant(char* idf);
void accesTab(char* idf,int i);
