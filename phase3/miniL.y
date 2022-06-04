%{
 #include <stdio.h>
 #include <stdlib.h>
 extern int currLine;
 extern int currPos;
 void yyerror(const char *msg);
 FILE* yyin;
  
  
 enum Type { Integer, Array };
struct Symbol {
  std::string name;
  Type type;
};
struct Function {
  std::string name;
  std::vector<Symbol> declarations;
};

std::vector <Function> symbol_table;


Function *get_function() {
  int last = symbol_table.size()-1;
  return &symbol_table[last];
}

bool find(std::string &value) {
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
      return true;
    }
  }
  return false;
}

void add_function_to_symbol_table(std::string &value) {
  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
}

void add_variable_to_symbol_table(std::string &value, Type t) {
  Symbol s;
  s.name = value;
  s.type = t;
  Function *f = get_function();
  f->declarations.push_back(s);
}

void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");
}

bool FuncStart = true;
int identnum = 0;
bool ifeq = false;
bool ifneq = false;
bool iflt= false;
bool ifgt = false;
bool iflte = false;
bool ifgte = false;
bool isrunning = true;
string milout;

%}

%union{
  char* cval;
  int ival;
}

%error-verbose
%start program
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY ENUM OF IF THEN ENDIF ELSE FOR WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token <ival> NUMBER
%token <cval> IDENT
%left ADD SUB
%left MULT DIV MOD
%right ASSIGN
%nonassoc UMINUS
%type <op_val> symbol 

%%
startprog:	program
		{}
		;

program:	/* empty { printf("program -> epsilon\n");*/ }
		| functions /*{ printf("program -> functions\n");*/ }
		;

functions:	/* empty */ { printf("functions -> epsilon\n"); }
		| function functions { printf("functions -> function functions\n"); }
    		;

function:	FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY { printf("function -> FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n"); }
		{if(FuncStart == true){
			milcode.append("func $1 \n");
			FuncStart = false;
		else{
			milcode.append("\n endfunc");
			}
		std::string func_name = $2;
  		add_function_to_symbol_table(func_name);
		;

declarations: 	/* empty */ { printf("declarations -> epsilon\n"); }
    		| declaration SEMICOLON declarations { printf("declarations -> declaration SEMICOLON declarations\n"); }
		| error
    		;

declaration:  	idents COLON ENUM L_PAREN idents R_PAREN { printf("declaration -> idents COLON ENUM L_PAREN idents R_PAREN\n"); }
    		| idents COLON INTEGER { printf("declaration -> idents COLON INTEGER\n"); }
    		| idents COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER { printf("declaration -> idents COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n"); }
    		 // add the variable to the symbol table.
  		std::string value = $1;
  		Type t = Integer;
  		add_variable_to_symbol_table(value, t);
		;

statements: /* empty */ { printf("statements -> epsilon\n"); }
    | statement SEMICOLON statements { printf("statements -> statement SEMICOLON statements\n"); }
    | error
    ;

statement: var ASSIGN exp { printf("statement -> var ASSIGN exp\n"); }
    | IF bool_exp THEN statements ENDIF {/* printf("statement -> IF bool_exp THEN statements ENDIF\n");*/ }
    | IF bool_exp THEN statements ELSE statements ENDIF { /*printf("statement -> IF bool_exp THEN statements ELSE statements ENDIF\n"); */}
    | WHILE bool_exp BEGINLOOP statements ENDLOOP {/* printf("statement -> WHILE bool_exp BEGINLOOP statements ENDLOOP\n"); */}
    | DO BEGINLOOP statements ENDLOOP WHILE bool_exp { /*printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_exp\n");*/ }
    | READ vars { /*printf("statement -> READ vars\n");*/ milcode.append(".<" + $1 + "\n");} //not really sure?
    | WRITE vars { /*printf("statement -> WRITE vars\n");*/ milcode.append(".>" + $1 + "\n"); }
    | CONTINUE { /*printf("statement -> CONTINUE\n"); */ milcode.append("continue\n");}
    | RETURN exp { /*printf("statement -> RETURN exp\n"); */}
    ;

bool_exp:  and_exp { printf("bool_exp -> and_exp\n"); }
    | and_exp OR bool_exp {/* printf("bool_exp -> and_exp OR bool_exp\n");*/ }
    ;

and_exp: relation_exp { printf("and_exp -> relation_exp\n"); }
	| relation_exp AND and_exp { printf("and_exp -> relation_exp AND and_exp\n"); }
	;


relation_exp: not_exp exp comp exp { printf("relation_exp -> not_exp exp comp exp\n"); }
    | not_exp TRUE { printf("relation_exp -> not_exp TRUE\n"); }
    | not_exp FALSE { printf("relation_exp -> not_exp FALSE\n"); }
    | not_exp L_PAREN bool_exp R_PAREN { printf("relation_exp -> not_exp L_PAREN bool_exp R_PAREN\n"); }
    ;

not_exp: /* empty */ { printf("not_exp -> epsilon\n"); }
	| NOT { printf("not_exp -> NOT\n"); }
	; 

comp: EQ { ifeq = true; ifneq = false; iflt = false; ifgt = false; iflte = false; ifgte= false; }
    | NEQ { ifneq = true; ifeq = false; iflt = false; ifgt = false; iflte = false; ifgte= false;  }
    | LT { iflt = true; ifeq = false; ifneq = false; ifgt = false; iflte = false; ifgte= false; }
    | GT { ifgt = true; ifeq = false; ifneq = false; iflt = false; iflte = false; ifgte= false; }
    | LTE { iflte = true; ifeq = false; ifneq = false; iflt = false; ifgt = false; ifgte= false; }
    | GTE { ifgte = true; ifeq = false; ifneq = false; iflt = false; ifgt = false; iflte= false;}
    ;

exps: /* empty */ { printf("exps -> epsilon\n"); }
	| exp	{ printf("exps -> exp\n"); }
    | exp COMMA exps { printf("exps -> exp COMMA exps\n"); }
    ;

exp:  multi_exp { printf("exp -> multi_exp\n"); }
    | multi_exp ADD exp { printf("exp -> multi_exp ADD exp\n"); }
    | multi_exp SUB exp { printf("exp -> multi_exp SUB exp\n"); }
    ;

multi_exp:  term { printf("multi_exp -> term\n"); }
    | term MULT multi_exp { printf("multi_exp -> term MULT multi_exp\n"); }
    | term DIV multi_exp { printf("multi_exp -> term DIV multi_exp\n"); }
    | term MOD multi_exp { printf("multi_exp -> term MOD multi_exp\n"); }
    ;

term: var { printf("term -> var\n"); }
    | NUMBER { printf("term -> NUMBER\n"); }
    | L_PAREN exp R_PAREN { printf("term -> L_PAREN exp R_PAREN\n"); }
    | SUB var { printf("term -> SUB var\n"); }
    | SUB NUMBER { printf("term -> SUB NUMBER\n"); }
    | SUB L_PAREN exp R_PAREN { printf("term -> SUB L_PAREN exp R_PAREN\n"); }
    | ident L_PAREN exps R_PAREN { printf("term -> ident L_PAREN exps R_PAREN\n"); }
    ;



vars: /* empty */ { printf("vars -> epsilon\n"); }
	| var { printf("vars -> var\n"); }
    | var COMMA vars { printf("vars -> var COMMA vars\n"); }
    ;

var: ident { printf("var -> ident\n"); }
    | ident L_SQUARE_BRACKET exp R_SQUARE_BRACKET { printf("var -> ident L_SQUARE_BRACKET exp R_SQUARE_BRACKET\n"); }
    ;

idents: /* empty */ { printf("idents -> epsilon\n"); }
	| ident { printf("idents -> ident\n"); }
    	| ident COMMA idents { printf("idents -> ident COMMA idents\n"); }
    	;

ident:	IDENT { printf("ident -> IDENT %s\n", $1); }
    ;


%%

int main(int argc, char **argv) {
   if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         printf("syntax: %s filename\n", argv[0]);
      }//end if
   }//end if
   
   yyparse(); // Calls yylex() for tokens.
   print_symbol_table();
   
   ofstream file; 
   file.open(""); //mil file name
   file << milcode;
   file.close(); //mil code is in file
     
   return 0;
}

void yyerror(const char *msg) {
   printf("** Line %d, position %d: %s\n", currLine, currPos, msg);
   exit(1);
}
