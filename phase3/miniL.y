%{
#include<stdio.h>
#include<string>
#include<vector>
#include<string.h>

extern int yylex(void);
void yyerror(const char *msg);
extern int currLine;

char *identToken;
int numberToken;
int  count_names = 0;


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

string make_temp() {
	string tempgenerator = "_temp";
	tempTable.push_back("_temp");
	return tempgenerator;
}


%}


%union {
  char *op_val;
}

%define parse.error verbose
%start prog_start
%token BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY
%token FUNCTION 
%token INTEGER 
%token WRITE
%token SUB ADD MULT DIV MOD
%token SEMICOLON COLON COMMA ASSIGN
%token <op_val> NUMBER 
%token <op_val> IDENT
%type <op_val> symbol 

%%

prog_start: functions
{
  printf("prog_start -> functions\n");
}

functions: 
/* epsilon */
{ 
  printf("functions -> epsilon\n");
}
| function functions
{ };

function: FUNCTION IDENT 
{
  // midrule:
  // add the function to the symbol table.
  std::string func_name = $2;
  add_function_to_symbol_table(func_name);
}
	SEMICOLON
	BEGIN_PARAMS declarations END_PARAMS
	BEGIN_LOCALS declarations END_LOCALS
	BEGIN_BODY statements END_BODY
{
  code += "func " + $2 + \n + $5 + $8 + $11 + "endfunc\n";
};

declarations: 
/* epsilon */
{
  $$ = "";
}
| declaration SEMICOLON declarations
{
  $$ = $1 + "\n" + $3;
};

declaration: 
	IDENT COLON INTEGER { printf("declaration -> idents COLON INTEGER\n"); }
{
  $$ = ". " + $1;

  // add the variable to the symbol table.
  std::string value = $1;
  Type t = Integer;
  add_variable_to_symbol_table(value, t);
};
	|IDENT COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER { printf("declaration -> idents COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n"); }
{ 
  $$ = ". " + $1 + ", " + $5;
  
  // add the variable to the symbol table.
  std::string value = $1;
  Type t = array;
  add_variable_to_symbol_table(value, t);
}
	|IDENT COLON ENUM L_PAREN idents R_PAREN
{
  //Why are you even using this?
}

statements: 
/* empty */
{
  $$ = '';
}
| statement SEMICOLON statements
{
  $$ = $1 + \n + $3;
};

statement: 
IDENT ASSIGN symbol ADD symbol
{
  string t1 = maketemp();
  $$ = ". " + t1 + "\n" + "+ " + t1 + ", " + $3 + ", " + $5 + "\n" + "= " + $1 + ", " + t1;
}
| IDENT ASSIGN symbol SUB symbol
{
  string t1 = maketemp();
  $$ = ". " + t1 + "\n" + "- " + t1 + ", " + $3 + ", " + $5 + "\n" + "= " + $1 + ", " + t1;
}
| IDENT ASSIGN symbol MULT symbol
{
  string t1 = maketemp();
  $$ = ". " + t1 + "\n" + "* " + t1 + ", " + $3 + ", " + $5 + "\n" + "= " + $1 + ", " + t1;
}
| IDENT ASSIGN symbol DIV symbol
{
  string t1 = maketemp();
  $$ = ". " + t1 + "\n" + "+ " + t1 + ", " + $3 + ", " + $5 + "\n" + "= " + $1 + ", " + t1;
}
| IDENT ASSIGN symbol MOD symbol
{
  string t1 = maketemp();
  $$ = ". " + t1 + "\n" + "% " + t1 + ", " + $3 + ", " + $5 + "\n" + "= " + $1 + ", " + t1;
}

| IDENT ASSIGN symbol
{
  string t1 = maketemp();
  $$ = ". " + t1 + "\n" + "= " + t1 + ", " + $3 + "\n" + "= " + $1 + ", " + t1;
}

| WRITE IDENT
{
  $$ = "> " + $2;
}
;

symbol: 
IDENT 
{ 
  $$ = $1; 
}
| NUMBER 
{
  $$ = $1; 
}

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
