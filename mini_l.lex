/* MINI-L Flex File
 *
 * Description:  Recognize MINI-L tokens
 **see http://www.cs.ucr.edu/~gkaur007/webpages/token_list_format.html **
 * 
 * Usage:
 *
 * Helpful Links:
 *     https://en.wikipedia.org/wiki/Lex_(software)
 */

  /*** Definitions ***/
%option noinput nounput noyywrap

%{
 #include "mini_l.h"
 #include "y.tab.h"
 #include "cstdlib"
 #include <string.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <unistd.h>

 int currLine = 1, currPos = 1;
%}

digit     [0-9]
alpha     [a-zA-Z]

comment     (##).*\n
identifier    {alpha}({digit}|{alpha})*(_({digit}|{alpha})+)*
number      ({digit}+(.{digit}+))|({digit}+)
inv_id_num    {digit}+{identifier}
inv_id_unscr    ({identifier}|{digit})+_+

%%
  /*** Rules  ***/
  /* Resereved Words */
"function"     { currPos += yyleng; /*printf("FUNCTION");*/ return FUNCTION; }
"beginparams"  { currPos += yyleng; return BEGIN_PARAMS; }
"endparams"    { currPos += yyleng; return END_PARAMS; }
"beginlocals"  { currPos += yyleng; return BEGIN_LOCALS; }
"endlocals"    { currPos += yyleng; return END_LOCALS; }
"beginbody"    { currPos += yyleng; return BEGIN_BODY; }
"endbody"      { currPos += yyleng; return END_BODY; }
"integer"      { currPos += yyleng; return INTEGER; }
"array"        { currPos += yyleng; return ARRAY; }
"of"           { currPos += yyleng; return OF; }
"if"           { currPos += yyleng; return IF; }
"then"         { currPos += yyleng; return THEN; }
"endif"        { currPos += yyleng; return ENDIF; }
"else"         { currPos += yyleng; return ELSE; }
"while"        { currPos += yyleng; return WHILE; }
"do"           { currPos += yyleng; return DO; }
"foreach"      { currPos += yyleng; return FOREACH; }
"in"           { currPos += yyleng; return IN; }
"beginloop"    { currPos += yyleng; return BEGINLOOP; }
"endloop"      { currPos += yyleng; return ENDLOOP; }
"continue"     { currPos += yyleng; return CONTINUE; }
"read"         { currPos += yyleng; return READ; }
"write"        { currPos += yyleng; return WRITE; }
"and"          { currPos += yyleng; return AND; }
"or"           { currPos += yyleng; return OR; }
"not"          { currPos += yyleng; return NOT; }
"true"         { currPos += yyleng; return TRUE; }
"false"        { currPos += yyleng; return FALSE; }
"return"       { currPos += yyleng; return RETURN; }
  /* Arithmetic Operators */
"-"            { currPos += yyleng; return SUB;}
"+"            { currPos += yyleng; return ADD;}
"*"            { currPos += yyleng; return MULT; }
"/"            { currPos += yyleng; return DIV;}
"%"            { currPos += yyleng; return MOD;}
  /* Comparison Operators */
"=="           { currPos += yyleng; return EQ; }
"<>"           { currPos += yyleng; return NEQ; }
"<"            { currPos += yyleng; return LT; }
">"            { currPos += yyleng; return GT; }
"<="           { currPos += yyleng; return LTE; }
">="           { currPos += yyleng; return GTE; }
  /* Identifiers and Numbers */
{identifier}   { currPos += yyleng;  yylval.cval = strdup(yytext); /*yylval.cval = yytext;*/ /*strcpy(yylval.cval,yytext);*/ /*strncpy(yylval.cval,yytext,yyleng);*/ return IDENT; }  /* yytext - string that contains matched text */
{number}       { currPos += yyleng; yylval.val = atoi(yytext); return NUMBER; }
  /* Other Special Symbols */
";"            { currPos += yyleng; return SEMICOLON; }
":"            { currPos += yyleng; return COLON; }
","            { currPos += yyleng; return COMMA; }
"("            { currPos += yyleng; return L_PAREN; }
")"            { currPos += yyleng; return R_PAREN; }
"["            { currPos += yyleng; return L_SQUARE_BRACKET; }
"]"            { currPos += yyleng; return R_SQUARE_BRACKET; }
":="           { currPos += yyleng; return ASSIGN; }
  /* Whitespace Characters */
"\n"           { currLine++; currPos = 1; }
[ \t]+         { currPos += yyleng; }
  /* Errors */
{comment}      { /* Ignore Comments printf("Comment Found: %s\n", yytext);*/ currPos += yyleng; }
{inv_id_num}   { printf("Error at line %d, colum %d: invalid identifier \"%s\" must begin with a letter\n", currLine, currPos, yytext); exit(0); }
{inv_id_unscr} { printf("Error at line %d, column %d: invalid identifier \"%s\" cannot end with an underscore\n", currLine, currPos, yytext); exit(0); }
.              { printf("!Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0); }
%%
