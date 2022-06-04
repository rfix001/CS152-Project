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
  $$ = "." + $1;

  // add the variable to the symbol table.
  std::string value = $1;
  Type t = Integer;
  add_variable_to_symbol_table(value, t);
};
	|IDENT COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER { printf("declaration -> idents COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n"); }
{ 
  $$ = "." + $1 + ',' + $5;
  
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
