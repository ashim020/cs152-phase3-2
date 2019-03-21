
%{
#include "heading.h"
#include <sstream>
int yyerror (const char* s);
int yylex (void);

//initially assume there is a main.
bool missing_main = false;
string itos(int);
string ctos(char*);
void map_push(string, Var);
bool map_find(string);
map<string, Var> vmap;
int temp_count = 0;
int label_count = 0;
void dne(string);
string* temp();
string* label();
string syn_create(string*, string*, string*, string);
string dot(string *);
void exp(Terminal &, Terminal, Terminal, string);
stack<airpod> airpod_stack;
bool pokerchips = false;
stringstream* igota21;
FILE *kris;
bool success = true;
%}

%union{
	int val;
	char* cval;
	struct {
    stringstream *code;
	} patek;

	struct Terminal Terminal;
}

%error-verbose

%start	prog
%token	FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOREACH IN BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET RETURN
%token <val> NUMBER
%token <cval> IDENT
%left MULT DIV MOD ADD SUB
%left LT LTE GT GTE EQ NEQ
%right NOT
%left AND OR
%right ASSIGN

%type <patek> prog
%type <Terminal> func func1 decl decl1 array stmt stmt1 asn_stmt if_stmt else_stmt while_stmt do_stmt read_stmt r_stmt write_stmt w_stmt cont_stmt ret_stmt bool_expr or_expr and_expr and_expr1 rel_expr rel_expr1 comp expr expr1 multi_expr multi_expr1 term term2 term3 var var2 number ident

%%
prog:	func prog 
		{
			$$.code = $1.code;
			*($$.code) << $2.code->str();
			if(!pokerchips){
				yyerror("Error. no main.");
			}
			igota21 = $$.code;
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
				} else if ((*$5.vars)[i].type == INT){
					*($$.code) << "= " << *((*$5.vars)[i].name) << ", " << "$"<< itos(i) << "\n";
				} else {
					yyerror("Error. passing in invalid type.");
				}
			}
			*($$.code) << $11.code->str() << "end func\n";
		}
			;

ident: IDENT 
		{
			string temp = $1;
			Var appleiphonexs = Var();
			appleiphonexs.type = FUNC;
			if(!map_find(temp)){
				map_push(temp, appleiphonexs);
			}
			$$.name = new string();
			*$$.name = temp;
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

decl: IDENT decl1 COLON array INTEGER 
		{
			$$.code = $2.code;
            $$.type = $2.type;
            $$.length = $2.length;
            $$.vars = $2.vars;

            //=================
            // if there is an issue. its right here. the stringstream concat.
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

decl1:	COMMA IDENT decl1 
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
				string s = $2;
				if(!map_find(s)){
					map_push(s,v);
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
			$$.length = $3.length;
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

stmt1:	stmt SEMICOLON stmt1 
		{
			$$.code = $1.code;
			*($$.code) << $3.code->str();
		}
	|	
		{
			$$.code = new stringstream();
		}
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
                *($$.code) << syn_create($1.value, $1.index, tmp, "[]=");
            }
            else{
                yyerror("Error: expression is null.");
            }
		}

if_stmt: IF bool_expr THEN stmt1 else_stmt ENDIF
		{
			$$.end = label();
			$$.begin = label();
			$$.code = new stringstream();
			*($$.code) << $2.code->str() << "?:= " << *$$.begin << ", " <<  *$2.name << "\n";
			if($5.begin != NULL){
				*($$.code) << ":= " << *$5.begin << "\n";
			 	*($$.code) << ": " << *($$.begin) << "\n" << $4.code->str() << ":= "+ *($$.end) + "\n";
                *($$.code) << ": " << *($5.begin) << "\n" << $5.code->str();
			} else {
				*($$.code) << ": " << *($$.end) << "\n" << ": " << *($$.begin) << "\n"  << $4.code->str();
			}
			*($$.code) << ": " << *($$.end) << "\n";
		}
		;

else_stmt: ELSE stmt1 
			{
				$$.code = $2.code;
				$$.begin = label();
			}
		|
			{
				$$.code = new stringstream();
				$$.begin = NULL;
			}
		;

while_stmt: WHILE bool_expr BEGINLOOP stmt1 ENDLOOP 
			{
				$$.code = new stringstream();
				$$.begin = label();
				$$.parent = label();
				$$.end = label();
				airpod p = airpod();
				p.parent = $$.parent;
				p.begin = $$.begin;
				p.end = $$.end;
				airpod_stack.push(p);
				*($$.code) << ": " << *($$.parent) << "\n" << $2.code->str() << "?:= " << *$$.begin << ", " << *$2.name << "\n" << ":=" << *($$.end) << "\n" << ": " << *($$.begin) << "\n" << $4.code->str() << ":=" << *($$.parent) << "\n" << ": " << *($$.end) << "\n";
                airpod_stack.pop();
			}
			;

do_stmt:	DO BEGINLOOP stmt1 ENDLOOP WHILE bool_expr 
			{
				$$.code = new stringstream();
				$$.begin = label();
				$$.parent = label();
				$$.end = label();
				airpod p = airpod();
				p.parent = $$.parent;
				p.begin = $$.begin;
				p.end = $$.end;
				airpod_stack.push(p);
				*($$.code) << ": " << *($$.begin) << "\n" << $3.code->str() << ": " << *($$.parent) << "\n" << $6.code->str() << "?:= " << *$$.begin << ", " << $6.name << "\n" << ": " << *($$.end) << "\n";
			    airpod_stack.pop();
			}
		;

read_stmt: READ var r_stmt 
			{
				$$.code = $2.code;
				if($2.type == INT){
					*($$.code) << ".< " << *$2.name << "\n";  
				} else {
					 *($$.code) << ".[]< " << *$2.name << ", " << $2.index << "\n"; 
				}
				*($$.code) << $3.code->str();
			}
		;

r_stmt: COMMA var r_stmt 
		{
			$$.code = $2.code;
			if($2.type == INT){
				*($$.code) << ".< " << *$2.name << "\n";
			} else {
				*($$.code) << ".[]< " << *$2.value << ", " << $2.index << "\n"; 
			}

			*($$.code) << $3.code->str();
		}
		|	
			{
				$$.code = new stringstream();
			}
		; 

write_stmt: WRITE var w_stmt 
			{
				$$.code = $2.code;
				if($2.type == INT){
					*($$.code) << ".> " << *$2.name << "\n";
				} else {
					*($$.code) << ".[]> " << *$2.value << ", " << *$2.index << "\n";
				}
				*($$.code) << $3.code->str();
			}
		;

w_stmt: COMMA var w_stmt 
		{
			$$.code = $2.code;
			if($2.type == INT){
				*($$.code) << ".> " << *$2.name << "\n";
			} else {
				*($$.code) << ".[]> " << *$2.value << ", " << $2.index << "\n"; 
			}

			*($$.code) << $3.code->str();
		}
		|	
			{
				$$.code = new stringstream();
			}
		; 

cont_stmt:	CONTINUE 
			{
				$$.code = new stringstream();
				if(airpod_stack.size() <= 0){
					yyerror("Error. invalid use of continue.");
				} else {
					airpod cont = airpod_stack.top();
					*($$.code) << ":= " << *cont.parent << "\n";
				}
			}
		;

ret_stmt:	RETURN expr 
			{
				$$.name = $2.name;
				$$.code = $2.code;
				*($$.code) << "ret " << *$$.name << "\n";
			}
		;


bool_expr:	and_expr or_expr 
			{
				$$.code = $2.code;
				*($$.code) << $2.code->str();
				if($2.name != NULL && $2.operator1 != NULL){
					$$.name = temp();
					*($$.code) << dot($$.name) << syn_create($$.name, $1.name, $2.name, *$2.operator1); 
				} else {
					$$.name = $1.name;
					$$.operator1 = $1.operator1;
				}
			}
		;

or_expr:	OR and_expr or_expr 
			{
				exp($$, $2, $3, "||");
			}
		|	
			{
				$$.code = new stringstream();
				$$.operator1 = NULL;
			}
		;

and_expr:	rel_expr and_expr1	
			{
				$$.code = $1.code;
				*($$.code) << $2.code->str();
				if($2.name != NULL && $2.operator1 != NULL){
					$$.name = temp();
					*($$.code) << dot($$.name) << syn_create($$.name, $1.name, $2.name, *$2.operator1);
				} else {
					$$.name = $1.name;
					$$.operator1 = $1.operator1;
				}
			}
		;

and_expr1:	AND rel_expr and_expr1 
			{
				exp($$, $2, $3, "&&");
			}
		|	
			{
				$$.code = new stringstream();
				$$.operator1 = NULL;
			}
		;

rel_expr:	rel_expr1	
			{
				$$.code = $1.code;
				$$.name = $1.name;
			}
		|	NOT rel_expr1	
			{
				$$.code = $2.code;
				$$.name = temp();
				*($$.code) << dot($$.name) << syn_create($$.name, $2.name, NULL, "!");
			}
		;

rel_expr1:	expr comp expr 
			{
				printf("rel1 a");
				$$.code = $1.code;
				*($$.code) << $2.code->str();
				*($$.code) << $3.code->str();
				$$.name = temp();
				*($$.code) << dot($$.name) << syn_create($$.name, $1.name, $3.name, *$2.operator1);
			}
		|	TRUE 
			{
				printf("rel1 b");
				$$.code = new stringstream();
				$$.name = new string();
				*$$.name = "1";
			}
		|	FALSE 
			{
				printf("rel1 c");
				$$.code = new stringstream();
				$$.name = new string();
				*$$.name = "0";
			}
		|	L_PAREN bool_expr R_PAREN 
			{
				printf("rel1 d");
				$$.code = $2.code;
				$$.name = $2.name;
			}
		;

comp:	EQ 
		{
			printf("comp b");
			$$.code = new stringstream();
			$$.operator1 = new string();
			*$$.operator1 = "==";
		}
	|	NEQ 
		{
			printf("comp c");
			$$.code = new stringstream();
			$$.operator1 = new string();
			*$$.operator1 = "!=";
		}
	|	LT 	
		{
			printf("comp d");
			$$.code = new stringstream();
			$$.operator1 = new string();
			*$$.operator1 = "<";
		}
	|	GT 	
		{
			printf("comp e");
			$$.code = new stringstream();
			$$.operator1 = new string();
			*$$.operator1 = ">";
		}
	|	GTE	
		{
			printf("comp f");
			$$.code = new stringstream();
			$$.operator1 = new string();
			*$$.operator1 = ">=";
		}
	|	LTE 
		{
			printf("comp g");
			$$.code = new stringstream();
			$$.operator1 = new string();
			*$$.operator1 = "<=";
		}
	;

expr:	multi_expr expr1 
		{
			printf("expr");
			$$.code = $1.code;
			*($$.code) << $2.code->str();
			if($2.name != NULL && $2.operator1 != NULL){
				$$.name = temp();
				*($$.code)<< dot($$.name) << syn_create($$.name, $1.name, $2.name, *$2.operator1);
			} else{
				$$.name = $1.name;
				$$.operator1 = $1.operator1;
			}
			$$.type = INT;
		}
			;

expr1:		ADD multi_expr expr1 
			{
				printf("expr1 a");
				exp($$, $2, $3, "+");
			}
		|	SUB multi_expr expr1 
			{
				printf("expr1 b");
				exp($$, $2, $3, "-");
			} 
		|	
			{
				printf("expr1 c");
				$$.code = new stringstream();
				$$.operator1 = NULL;
			}	
		;

multi_expr:		term multi_expr1 
			{
				printf("mult");
				$$.code = $1.code;
				*($$.code) << $2.code->str();
				if($2.name != NULL && $2.operator1 != NULL){
					$$.name = temp();
					*($$.code)<< dot($$.name)<< syn_create($$.name, $1.name, $2.name, *$2.operator1);
				} else {
					$$.name = $1.name;
					$$.operator1 = $1.operator1;
				}
			}
				;	

multi_expr1:	MULT term multi_expr1 
				{
					printf("mult1 a");
					exp($$, $2, $3, "*");
				}
		|		DIV term multi_expr1 
				{
					printf("mult1 b");
					exp($$, $2, $3, "/");
				}
		|		MOD term multi_expr1 
				{
					printf("mult1 c");
					exp($$, $2, $3, "%");
				}
		|		
			{
				printf("mult1 d");
				$$.code = new stringstream();
				$$.operator1 = NULL;
			}
		;

term:	term2 
		{
			printf("term a");
			$$.code = $1.code;
			$$.name = $1.name;
		}
	|	SUB term2 
		{
			printf("term b");
			$$.code = $2.code;
			$$.name = temp();
			string temp = "-1";
			*($$.code)<< dot($$.name) << syn_create($$.name, $2.name, &temp, "*");
		}
	|	IDENT L_PAREN term3 R_PAREN 
		{
			printf("term c");
			$$.code = $3.code;
			$$.name = temp();
			*($$.code) << dot($$.name) << "call " << $1 << ", " << *$$.name << "\n";
			string temp = $1;
			dne(temp);
		}
	;

term2:		var 
		{
			printf("term2 a");
			$$.code = $1.code;
			$$.name = $1.name;
			$$.index = $1.index;
		}
		|	number 
			{
				printf("term2 b");
				$$.code = $1.code;
				$$.name = $1.name;
				*$$.name = *$1.name;
			}
		|	L_PAREN expr R_PAREN 
			{
				printf("term2 c");
				$$.code = $2.code;
				$$.name = $2.name;
			}
		; 

term3:		expr COMMA term3 
		{
			printf("term3 a");
			$$.code = $1.code;
			*($$.code) << $3.code->str();
			*($$.code) << "param " << *$1.name;
		}
		|	expr 
			{
				term3 b
				$$.code = $1.code;
				*($$.code) << new stringstream();
				*($$.code) << "param " << *$1.name;

			}
		|	
			{
				printf("term3 c");
				$$.code = new stringstream();
			}
		;


var:	IDENT var2 
	{
		printf("var");
		$$.code = $2.code;
		$$.type = $2.type;
		string tonystark = $1;
		dne(tonystark);
		if(map_find(tonystark) && vmap[tonystark].type != $2.type){
			if($2.type == INT_ARR){
				string errmsg = "Error: " + tonystark + " is not array type";
				yyerror(errmsg.c_str());
			} else if($2.type == INT){
				string errmsg = "Error: no index specified.";
				yyerror(errmsg.c_str());
			}
		}
		if ($2.index == NULL){
			$$.name = new string();
			*$$.name = $1;
		} else {
			$$.index =$2.index;
			$$.name = temp();
			string* pepperpots = new string();
			*pepperpots = $1;
			*($$.code) << dot($$.name) << syn_create($$.name, pepperpots, $2.index, "=[]");
			$$.value = new string();
			*$$.value = $1;
		}
	}
	;

var2:	L_SQUARE_BRACKET expr R_SQUARE_BRACKET {
			$$.code = $2.code;
			$$.name = NULL;
			$$.index = $2.name;
			$$.type = INT_ARR;
		}
	|
		{
			printf("var2");
			$$.code = new stringstream();
			$$.index = NULL;
			$$.name = NULL;
			$$.type = INT;
		}	
	;

number:	NUMBER 
		{
			printf("number");
			$$.code = new stringstream();
			$$.name = new string();
			*$$.name = itos($1);
			$$.length = $1;
		}

%%

/*
string ctos (char* str){
	ostringstream char2str;
	char2str << str;
	return char2str.str();
}
*/

void dne(string key){
	if(!map_find(key)){
		string temp = "Error: " + key + " DNE.";
		yyerror(temp.c_str());
	} 
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

void exp(Terminal &a, Terminal b, Terminal c, string d){
	a.code = b.code;
	*(a.code) << c.code->str();
	if(c.operator1 == NULL){
		a.name = b.name;
		a.operator1 = new string();
		*a.operator1 = d;
	} else {
		a.name = temp();
		a.operator1 = new string();
		*a.operator1 = d;

		*(a.code) << dot(a.name) << syn_create(a.name, b.name, c.name, *c.operator1);
	}
}

string* label() {
	string* temp = new string();
	ostringstream os;
	os << label_count;
	*temp = "_label_" + os.str();
	label_count++;
	return temp;
}

string syn_create(string *name, string *first, string *second, string operator1) 
{
	return (operator1 == "!") ? operator1 + " " + *name + ", " + *first + "\n" : operator1 + " " + *name + ", " + *first + ", "+ *second +"\n";
}

string dot(string *s)
{ 
	return ". " + *s + "\n"; 
}

int main(int argc, char **argv) {

    if ( (argc > 1) && (kris = fopen(argv[1],"r")) == NULL){
        printf("syntax: %s filename\n", argv[0]);
        return 1;
    }

    yyparse();

    if(success)
    {
        ofstream file;
        file.open("mil_code.mil");
        file << igota21->str();
        file.close();
    }
    else{
        cout << "**Errors exist, fix to compile code**" << endl;
    }


    return 0;
}
int yyerror(const char *s)
{
	extern int currLine, currPos;

  	extern char *yytext;	

  	//printf("Syntax error at line %d: invalid %s", currLine, yytext);
  	printf("At line %d: %s\n",currLine,s);
  	success = false;
  	exit(1);
}
