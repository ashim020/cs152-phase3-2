%{
#include <stdio.h>
#include <stdlib.h>

int yyerror (const char* s);
int yylex (void);

FILE * yyin;
%}	

//Bison Declarations

%define parse.error verbose

%union{
	int  val;
	char* cval;
}

%start	prog
%token	FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOREACH IN BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET RETURN
%token <val> NUMBER
%token <cval> IDENT
%left MULT DIV MOD ADD SUB
%left LT LTE GT GTE EQ NEQ
%right NOT
%left AND OR
%right ASSIGN

%%
prog:	func prog {printf("prog -> func prog\n");}
	|	{printf("prog -> epsilon\n");}
	;

func: 	FUNCTION ident SEMICOLON BEGIN_PARAMS func1 END_PARAMS BEGIN_LOCALS func1 END_LOCALS BEGIN_BODY stmt1 END_BODY {printf("FUNCTION ident SEMICOLON BEGIN_PARAMS func1 END_PARAMS BEGIN_LOCALS func1 END_LOCALS BEGIN_BODY stmt1 END_BODY\n"); }
			;

func1:	decl SEMICOLON func1 {printf("func1 -> decl SEMICOLON func1\n");}
	|	{printf("func1 -> epsilon\n");}
	;

decl: ident decl1 COLON array INTEGER {printf("decl -> ident decl1 COLON array INTEGER\n");}
	;

decl1:	COMMA ident decl1 {printf("decl1 -> COMMA ident decl\n");}
	|	{printf("decl1 -> epsilon\n");}
	;

array: ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF {printf("decl2 -> ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF\n");}
	|	{printf("array -> epsilon\n");}
	;

stmt:	asn_stmt {printf("stmt -> asn_stmt\n");}
	|	if_stmt	{printf("stmt -> if_stmt\n");}
	|	while_stmt {printf("stmt -> while_stmt\n");}
	|	do_stmt {printf("stmt -> do_stmt\n");}
	|	read_stmt {printf("stmt -> read_stmt\n");}
	|	write_stmt {printf("stmt -> write_stmt\n");}
	|	cont_stmt {printf("stmt -> cont_stmt\n");}
	|	ret_stmt {printf("stmt -> ret_stmt\n");}
	;

stmt1:	stmt SEMICOLON stmt1 {printf("stmt1 -> stmt SEMICOLON\n");}
	|	stmt SEMICOLON {printf("stmt1 -> stmt SEMICOLON stmt1\n");}
	;

asn_stmt: var ASSIGN expr {printf("asn_stmt -> var ASSIGN expr\n");}

if_stmt: IF bool_expr THEN stmt1 else_stmt	{printf("if_stmt -> IF bool_expr THEN stmt1 else_stmt\n");}
		;

else_stmt: ELSE stmt1 ENDIF {printf("else_stmt -> ELSE stmt1 ENDIF\n");}
		|	ENDIF {printf("else_stmt -> ENDIF\n");}
		;

while_stmt: WHILE bool_expr BEGINLOOP stmt1 ENDLOOP {printf("while_stmt -> WHILE bool_expr BEGINLOOP stmt1 ENDLOOP\n");}
			;

do_stmt:	DO BEGINLOOP stmt1 ENDLOOP WHILE bool_expr {printf("do_stmt -> DO BEGINLOOP stmt1 ENDLOOP WHILE bool_expr\n");}
		;

read_stmt: READ var r_w_stmt {printf("read_stmt -> READ var r_w_stmt\n");}
		;

write_stmt: WRITE var r_w_stmt {printf("read_stmt -> WRITE var r_w_stmt\n");}
		;

r_w_stmt: COMMA var r_w_stmt {printf("r_w_stmt -> COMMA var r_w_stmt\n");}
		|	{printf("r_w_stmt -> epsilon\n");}
		; 

cont_stmt:	CONTINUE {printf("cont_stmt -> CONTINUE\n");}
		;

ret_stmt:	RETURN expr {printf("ret_stmt -> RETURN expr\n");}
		;


bool_expr:	and_expr or_expr {printf("bool_expr -> and_expr or_expr\n");}
		;

or_expr:	OR and_expr or_expr {printf("or_expr -> OR and_expr or_expr\n");}
		|	{printf("or_expr -> epslion\n");}
		;

and_expr:	rel_expr and_expr1	{printf("and_expr -> rel_expr and_expr1\n");}
		;

and_expr1:	AND rel_expr and_expr1 {printf("and_expr1 -> AND rel_expr and_expr1\n");}
		|	{printf("and_expr1 -> epsilon\n");}
		;

rel_expr:	rel_expr1	{printf("rel_expr -> rel_expr1\n");}
		|	NOT rel_expr1	{printf("rel_expr -> NOT rel_expr1\n");}
		;

rel_expr1:	expr comp expr {printf("rel_expr1 -> expr comp expr\n");}
		|	TRUE {printf("rel_expr1 -> TRUE\n");}
		|	FALSE {printf("rel_expr1 -> FALSE\n");}
		|	L_PAREN bool_expr R_PAREN {printf("rel_expr1 -> L_PAREN or_epxr R_PAREN\n");}
		;

comp:	EQ {printf("comp -> EQ\n");};
	|	NEQ {printf("comp -> NEQ\n");}
	|	LT 	{printf("comp -> LT\n");}
	|	GT 	{printf("comp -> GT\n");}
	|	GTE	{printf("comp -> GTE\n");}
	|	LTE {printf("comp -> LTE\n");}
	;

expr:	multi_expr expr1 {printf("expr -> multi_expr expr1\n");}
			;

expr1:		ADD multi_expr expr1 {printf("expr1 -> ADD multi_expr expr1\n");}
		|	SUB multi_expr expr1 {printf("expr1 -> SUB multi_expr expr1\n");} 
		|	{printf("expr1 -> epsilon\n");}	
		;

multi_expr:		term multi_expr1 {printf("multi_expr -> term multi_expr1\n");}
				;	

multi_expr1:	MULT term multi_expr1 {printf("multi_expr -> MULT term multi_expr\n");}
		|		DIV term multi_expr1 {printf("multi_expr -> DIV term multi_expr\n");}
		|		MOD term multi_expr1 {printf("multi_expr -> MOD term multi_expr\n");}
		|		{printf("multi_expr -> epsilon\n");}
		;

term:	term2 {printf("term -> term2\n");}
	|	SUB term2 {printf("term1 -> SUB term2\n");}
	|	ident L_PAREN term3 R_PAREN {printf("term -> ident L_PAREN term3 R_PAREN\n");}
	;

term2:		var {printf("term2 -> var\n");}
		|	number {printf("term2 -> number\n");}
		|	L_PAREN expr R_PAREN {printf("term2 -> L_PAREN expr R_PAREN\n");}
		; 

term3:		expr COMMA term3 {printf("term3 -> expr COMMA term3\n");}
		|	expr {printf("term3 -> expr\n");}
		|	{printf("term3 -> epsilon\n");}
		;


var:	ident {printf("var -> ident\n");}
	|	ident L_SQUARE_BRACKET expr R_SQUARE_BRACKET {printf("var -> ident L_SQUARE_BRACKET expr R_SQUARE_BRACKET\n");}
	;

ident:	IDENT {printf("ident -> IDENT %s\n", $1);}
	;

number:	NUMBER {printf("number -> NUMBER %d\n", $1); }

%%

int main (int argc, char ** argv)
{
  if(argc >= 2)
  {
     yyin = fopen(argv[1], "r");
     if(yyin == NULL)
     {
        yyin = stdin;
     }
  }
  else
  {
     yyin = stdin;
  }
  yyparse();

  return 0;
}

int yyerror(const char *s)
{
	extern int currLine, currPos;

  	extern char *yytext;	

  	//printf("Syntax error at line %d: invalid %s", currLine, yytext);
  	printf("At line %d: %s\n",currLine,s);

  	exit(1);
}
