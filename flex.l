%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "bison.tab.h"

int ligne=1;
int colonne=0;

extern YYSTYPE yylval;

%}

%option yylineno

maj [A-Z]
lettre [a-zA-Z]
chiffre [0-9]
INTEGER [-]{chiffre}+|{chiffre}+
CHAR '.'
Tab [\t]
IDF {maj}({lettre}|{chiffre})*
FLOAT [-][0-9]+"."[0-9]+|[0-9]+"."[0-9]+
COMMENTAIRE ("#"){CHAR}*
NOUVELLE_LIGNE [\n]

%%
"in range" { colonne+=yyleng; return IN_RANGE; }
" " {colonne++;}
{NOUVELLE_LIGNE} 	{ligne++; colonne=0; return NOUVELLE_LIGNE;}
{Tab}				{colonne++; return TAB;}
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
"=" 				{ colonne+=yyleng;  return AFFECTATION;}
{COMMENTAIRE} 		{ colonne+=yyleng; yylval.chaine=strdup(yytext); printf("commentaire \n"); return COMMENTAIRE;}
{CHAR} 				{ colonne+=yyleng; yylval.chaine=strdup(yytext); return CHAR; }
{IDF} 		{
						if(yyleng <8) {
							colonne+=yyleng;
							yylval.chaine=strdup(yytext);
							return IDF;
						}else{
							printf(" Erreur lexicale a la ligne: %d, colonne: %d :Identificateur trop long\n",ligne,colonne);
						}
					}
{INTEGER} 			{ colonne+=yyleng; yylval.chaine=strdup(yytext); return INTEGER;}
{FLOAT} 			{  colonne+=yyleng; yylval.chaine=strdup(yytext); return FLOAT;}

.printf("Lexical error : ligne : %d ,colonne : %d\n",ligne,colonne);

%%

int yywrap(){
 return 1;
}
