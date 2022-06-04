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
  $$ = $1 + "\n";
};

declaration: 
	IDENT COLON INTEGER
{
  $$ = "." + $1;

  // add the variable to the symbol table.
  std::string value = $1;
  Type t = Integer;
  add_variable_to_symbol_table(value, t);
};

statements: 
statement SEMICOLON
{
  printf("statements -> statement ;\n");
}
| statement SEMICOLON statements
{
  printf("statements -> statement ; statements\n");
};

statement: 
IDENT ASSIGN symbol ADD symbol
{
  printf("statement -> IDENT := symbol + symbol\n");
}
| IDENT ASSIGN symbol SUB symbol
{
  printf("statement -> IDENT := symbol - symbol\n");
}
| IDENT ASSIGN symbol MULT symbol
{
  printf("statement -> IDENT := symbol * symbol\n");
}
| IDENT ASSIGN symbol DIV symbol
{
  printf("statement -> IDENT := symbol / symbol\n");
}
| IDENT ASSIGN symbol MOD symbol
{
  printf("statement -> IDENT := symbol %% symbol\n");
}

| IDENT ASSIGN symbol
{
  printf("statement -> IDENT := symbol\n");
}

| WRITE IDENT
{
  printf("statement -> WRITE IDENT\n");
}
;

symbol: 
IDENT 
{
  printf("symbol -> IDENT %s\n", $1); 
  $$ = $1; 
}
| NUMBER 
{
  printf("symbol -> NUMBER %s\n", $1);
  $$ = $1; 
}
