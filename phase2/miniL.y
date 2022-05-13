%{
  #include <stdio.h>
  #include <stdlib.h>
  void yyerror(const char *msg);
  extern int currLine;
  extern int currPos;
  FILE* yyin;
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
%nonassoc UMINUS

%%
program:	/* empty */ { printf("program -> epsilon\n"); }
		| functions { printf("program -> functions\n"); }
		;

functions:	/* empty */ { printf("functions -> epsilon\n"); }
		| function functions { printf("functions -> function functions\n"); }
    		;

function:	FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY { printf("function -> FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n"); }
		;

declarations: 	/* empty */ { printf("declarations -> epsilon\n"); }
    		| declaration SEMICOLON declarations { printf("declarations -> declaration SEMICOLON declarations\n"); }
    		;

declaration:  	idents COLON ENUM L_PAREN idents R_PAREN { printf("declaration -> idents COLON ENUM L_PAREN idents R_PAREN\n"); }
    		| idents COLON INTEGER { printf("declaration -> idents COLON INTEGER\n"); }
    		| idents COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER { printf("declaration -> idents COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n"); }
    		;

statements: /* empty */ { printf("statements -> epsilon\n"); }
    | statement SEMICOLON statements { printf("statements -> statement SEMICOLON statements\n"); }
    ;

statement: var ASSIGN exp { printf("statement -> var ASSIGN exp\n"); }
    | IF bool_exp THEN statements ENDIF { printf("statement -> IF bool_exp THEN statements ENDIF\n"); }
    | IF bool_exp THEN statements ELSE statements ENDIF { printf("statement -> IF bool_exp THEN statements ELSE statements ENDIF\n"); }
    | WHILE bool_exp BEGINLOOP statements ENDLOOP { printf("statement -> WHILE bool_exp BEGINLOOP statements ENDLOOP\n"); }
    | DO BEGINLOOP statements ENDLOOP WHILE bool_exp { printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_exp\n"); }
    | READ vars { printf("statement -> READ vars\n"); }
    | WRITE vars { printf("statement -> WRITE vars\n"); }
    | CONTINUE { printf("statement -> CONTINUE\n"); }
    | RETURN exp { printf("statement -> RETURN exp\n"); }
	| var error {yyerrok;}
    ;

bool_exp:  and_exp { printf("bool_exp -> and_exp\n"); }
    | and_exp OR bool_exp { printf("bool_exp -> and_exp OR bool_exp\n"); }
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

comp: EQ { printf("comp -> EQ\n"); }
    | NEQ { printf("comp -> NEQ\n"); }
    | LT { printf("comp -> LT\n"); }
    | GT { printf("comp -> GT\n"); }
    | LTE { printf("comp -> LTE\n"); }
    | GTE { printf("comp -> GTE\n"); }
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
   return 0;
}

void yyerror(const char *msg) {
   printf("** Line %d, position %d: %s\n", currLine, currPos, msg);
}

