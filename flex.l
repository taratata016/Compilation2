%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "bison.tab.h"

int ligne=1;
int colonne=0;
	const int TABULATION = 4;
	int current_indentation = 0;
	int indent_level = 0;

extern YYSTYPE yylval;

%}

%option yylineno
COMMENTAIRE #.*\n
maj [A-Z]
miniscule [a-z]
chiffre [0-9]
Tab [\t]
IDF [a-zA-Z][a-zA-Z0-9]*

NOUVELLE_LIGNE [\n]

INTEGER [-]{chiffre}+|{chiffre}+
FLOAT [-][0-9]+"."[0-9]+|[0-9]+"."[0-9]+
CHAR '.'
%x indent
%s normal

%%
<indent>" " {colonne+= 1;
			 current_indentation++;}
<indent>"\t" {colonne+= TABULATION;
			  current_indentation = (current_indentation + TABULATION) & ~(TABULATION-1);}
<indent>"\n" { ligne = yylineno;
			   current_indentation = 0;}
<indent><<EOF>> { if (indent_level != 0) {
					indent_level--;
                    return mc_unindent;
                }
		  		return 0;}
<indent>.        {
                   unput(*yytext);
                   if (current_indentation > indent_level) {
                       indent_level++;
                       return mc_indent;
                   } else if (current_indentation < indent_level) {
                       indent_level--;
                       return mc_unindent;
                   } else {
                       BEGIN normal;
                   }
                 }

" " {colonne++;}
"in range" { colonne+=yyleng; return IN_RANGE; }
"if" 				{ colonne+=yyleng;  return IF;}
"elif" 				{colonne+=yyleng; return ELIF; }
"else" 				{colonne+=yyleng; return ELSE; }
"for" 				{ colonne+=yyleng;  return FOR; }
"int" 		{ colonne+=yyleng;  return MC_INT; }
"char" 				{ colonne+=yyleng;  return MC_CHAR; }
"float" 			{ colonne+=yyleng; return MC_FLOAT; }
"while" 			{ colonne+=yyleng;  return WHILE; }
"+" 				{ colonne+=yyleng; return PLUS; }
"," 				{colonne+=yyleng;  return VIRGULE;}
"]" 				{colonne+=yyleng; return CROCHETFERME;}
"[" 				{ colonne+=yyleng; return CROCHETOUVERT;}
")" 				{ colonne+=yyleng; return PARENTHESEFERME;}
"(" 				{ colonne+=yyleng; return PARENTHESEOUVERT;}
":" 				{colonne+=yyleng;  return DEUXPOINTS; }
";" 				{ colonne+=yyleng; return POINTVIRGULE;}
"*" 				{ colonne+=yyleng;  return MULTI;}
"/" 				{ colonne+=yyleng;  return DIV;}
"^" 				{ colonne+=yyleng; return PUISSANCE;}
"-" 				{ colonne+=yyleng; return MOIN;}
"and" 				{colonne+=yyleng; return AND;}
"or" 				{colonne+=yyleng; return OR;}
"!" 				{colonne+=yyleng; return DIFF;}
">" 				{colonne+=yyleng; return SUPP;}
"<" 				{ colonne+=yyleng; return INF;}
"==" 				{ colonne+=yyleng; return EGALE;}
"!=" 				{ colonne+=yyleng; return NONEGALE;}
">=" 				{ colonne+=yyleng; return SUPEGALE;}
"<=" 				{ colonne+=yyleng; return INFEGALE;}
"=" 				{ colonne+=yyleng;  return '=';}
{COMMENTAIRE} 		{ colonne+=yyleng;}
{CHAR} 				{ colonne+=yyleng; yylval.chaine=strdup(yytext); return CHAR; }
{IDF} 		{			if(yyleng <8) {
							colonne+=yyleng;
							yylval.chaine=strdup(yytext);
							return IDF;
						}else{
							printf(" Erreur lexicale a la ligne: %d, colonne: %d :Identificateur trop long\n",ligne,colonne);
						}
					}
{FLOAT} 			{ colonne+=yyleng; yylval.chaine=strdup(yytext); return FLOAT;}
{INTEGER} 		{ colonne+=yyleng; yylval.chaine=strdup(yytext); return INTEGER;}

[ \r] { colonne += yyleng;}
\t { colonne += TABULATION;
	 current_indentation = (current_indentation + TABULATION) & ~(TABULATION-1);
	 BEGIN(indent);}
\n { ligne = yylineno;
	 current_indentation = 0;
	 colonne = 1;
	 BEGIN(indent);
	 return NOUVELLE_LIGNE;}
<<EOF>> { if (indent_level != 0) {
			indent_level--;
            return mc_unindent;
        }
		return 0;}

.printf("Lexical error : ligne : %d ,colonne : %d\n",ligne,colonne);

%%

int yywrap(){
 return 1;
}
