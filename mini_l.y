%{
#include <stdio.h>
#include <stdlib.h>

int yyerror (const char* s);
int yylex (void);

FILE * yyin;
//initially assume there is a main.
bool missing_main = false;
string itos(int);
string ctos(char*);
void map_push(string, Var);
void map_find(string, Var);
map<string, Var> vmap;
int temp_count = 0;
int label_count = 0;
string* temp();
string* label();
string syn_create(string*, string*, string*, string);
string dot(string *);
%}

enum Type {INT,INT_ARR,FUNC};

struct Var{
    string *name;
    string *value;
    //vector
    Type type;
    int length;
    string *index;
} ;


struct Terminal{
   stringstream *code;
   string *name;
   string *value;
   string *operator;
   string *begin;
   string *parent;
   string *end;
   Type type;
   int length;
   string *index;
   vector<string> *ids;
   vector<Var> *vars; 
};

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
prog:	func prog 
		{
			$$.code = $1.code;
			*($$.code) << $2.code->str();
			if(!no_main){
				yyerror("Error. no main.");
			}
			all_code = $$.code;
		}
	|	
		{
			$$.code = new stringstream();
		}
	;

func: 	FUNCTION ident SEMICOLON BEGIN_PARAMS func1 END_PARAMS BEGIN_LOCALS func1 END_LOCALS BEGIN_BODY stmt1 END_BODY 
		{
			$$.code = new stringstream();
			string place_holder = *$2.name;
			if (place_holder.compare("main") == 0){
				missing_main = true;
			}
			*($$.code) << "func " << place_holder << "\n" << $5.code->str() << $8.code->str();
			for(int i = 0; i < $5.vars->size(); ++i){
				if((*$5.vars)[i].type == INT_ARR){
					yyerror("Error in passing in to array.");
				} else if ((*5.vars)[i].type == INT){
					*($$.code) << "= " << *((*$5.vars)[i].name) << ", " << "$"<< itos(i) << "\n";
				} else {
					yyerror("Error. passing in invalid type.");
				}
			}
			*($$.code) << $11.code->str() << $13.code->str();
		}
			;

func1:	decl SEMICOLON func1 
		{
			$$.code = $1.code;
			$$.vars = $1.vars;
			for(int i = 0; i < $3.vars->size(); ++i){
				$$.vars->push_back((*$3.vars)[i]);
			}
			*($$.code) << $3.code->str();
		}
	 |	
		{
			$$.code = new stringstream();
			$$.vars = new vector<Var>();
		}
	;

decl: ident decl1 COLON array INTEGER 
		{
			$$.code = $2.code;
            $$.type = $2.type;
            $$.length = $2.length;
            $$.vars = $2.vars;

            //=================
            // if there is an issue. its right here. the stringstream concat.
            $$.code << $4.code;
            $$.type << $4.type;
            $$.length << $4.length;
            $$.vars << $4.vars;
			//=================

            Var v = Var();
            v.type = $2.type;
            v.length = $2.length;
            v.name = new string();
            *v.name = $1;
            $$.vars->push_back(v);
            if($2.type == INT_ARR){
                if($2.length <= 0){
                    yyerror("ERROR: array size");
                }
                *($$.code) << ".[] " << $1 << ", " << $2.length << "\n";
                string s = $1;
                if(!map_find(s)){
                    map_push(s,v);
                }
                else{
                    string tmp = "Error. (" + s + ") is defined more than once.";
                    yyerror(tmp.c_str());
                }
            }

            else if($2.type == INT){
                *($$.code) << ". " << $1 << "\n";
                string s = $1;
                if(!map_find(s)){
                    map_push(s,v);
                } else{
                    string tmp = "Error. (" + s + ") is defined more than once.";
                    yyerror(tmp.c_str());
                }
            } else{
                    yyerror("ERROR: invalid type");
            }



		}
	;

decl1:	COMMA ident decl1 
		{
			$$.code = $3.code;
			$$.type = $3.type;
			$$.length = $3.length;
			$$.vars = $3.vars;
			Var v = Var();
			v.type = $3.type;
			v.length = $3.length;
			v.name = new string ();
			*v.name = $2;
			$$.vars->push_back(v);

			if($3.type == INT_ARR){
				*($$.code) << ".[] " << $2 << ", " << $3.length << "\n";
				string s = %2;
				if(!check_maps(s)){
					in_map(s,v);
				} else {
					string tmp = "Error. (" + s + ") is defined more than once.";
					yyerror(tmp.c_str());
				}
			} else if ($3.type == INT) {
				*($$.code) << ". " << $2 << "\n";
				string s = $2;
				if(!map_find(s)){
					map_push(s,v);
				} else {
					string tmp = "Error. (" + s + ") is defined more than once.";
				}
			}
		}
	|	
		{
			$$.code = new stringstream();
            $$.vars = new vector<Var>();
            $$.type = INT;
            $$.length = 0;
		}
	;

array: ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF 
		{
			$$.length = $3;
	        $$.vars = new vector<Var>();
	        $$.code = new stringstream();
	        $$.type = INT_ARR;
		}

	|	

		{
	        $$.type = INT;
	        $$.vars = new vector<Var>();
	        $$.length = 0;
			$$.code = new stringstream();
		}
	;

stmt:	asn_stmt 
		{
			$$.code = $1.code;
		}

	|	if_stmt	
		{
			$$.code = $1.code;
		}

	|	while_stmt 
		{
			$$.code = $1.code;
		}

	|	do_stmt 
		{
			$$.code = $1.code;
		}

	|	read_stmt 
		{
			$$.code = $1.code;
		}

	|	write_stmt 
		{
			$$.code = $1.code;
		}

	|	cont_stmt 
		{
			$$.code = $1.code;
		}

	|	ret_stmt 
		{
			$$.code = $1.code;
		}
	;

stmt1:	stmt SEMICOLON stmt1 {printf("stmt1 -> stmt SEMICOLON\n");}
	|	stmt SEMICOLON {printf("stmt1 -> stmt SEMICOLON stmt1\n");}
	;

asn_stmt: var ASSIGN expr 
		{
			$$.code = $1.code;
			*($$.code) << $3.code->str();
			if($1.type == INT && $3.type == INT){
               *($$.code) << "= " << *$1.name << ", " << *$3.name << "\n";
            }
            else if($1.type == INT && $3.type == INT_ARR){
                *($$.code) << syn_create($1.name, $3.name, $3.index, "=[]");
            }
            else if($1.type == INT_ARR && $3.type == INT && $1.value != NULL){
                *($$.code) << syn_create($1.value, $1.index, $3.name, "[]=");
            }
            else if($1.type == INT_ARR && $3.type == INT_ARR){
                string *tmp = temp();
                *($$.code) << dot(tmp) << syn_create(tmp, $3.name, $3.index, "=[]");
                *($$.code) << syn_create($1.value, "[]=", $1.index, tmp);
            }
            else{
                yyerror("Error: expression is null.");
            }
		}

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

string ctos (char* str){
	ostringstream char2str;
	char2str << str;
	return char2str.str();
}

string itos (int str){
	ostringstream int2str;
	int2str << str;
	return int2str.str();
}

void map_push(string name, Var v){
    if(vmap.find(name) == vmap.end()){
        vmap[name] = v;
    }
    else{
        string tmp = "ERROR: " + name + " already exists";
        yyerror(tmp.c_str());
    }
}

bool map_find(string name){
    if(vmap.find(name) == vmap.end()){
        return false;
    }
    return true;
}

string* temp() {
	string* temp = new string();
	ostringstream os;
	os << temp_count;
	*temp = "_temp_" + os.str();
	temp_count++;
	return temp;
}

string* label() {
	string* temp = new string();
	ostringstream os;
	os << label_count;
	*temp = "_label_" + os.str();
	label_count++;
	return temp;
}

string syn_create(string *name, string *first, string *second, string operator) 
{
	return (operator == "!") ? operator + " " + *name + ", " + *first + "\n" : operator + " " + *name + ", " + *first + ", "+ *second +"\n"
}

string dot(string *s)
{ 
	return ". " + *s + "\n"; 
}

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
