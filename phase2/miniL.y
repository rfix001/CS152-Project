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
%start input
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY ENUM OF IF THEN ENDIF ELSE FOR WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN EQ NEQ LT GT LTE GTE IDENT SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token <ival> NUMBER
%token <cval> IDENTIFIER
%left ADD SUB
%left MULT DIV MOD
%nonassoc UMINUS

%%
input:		/* empty */ { printf("input -> epsilon"); }
		| program { printf("input -> program"); }
		;


program:	functions { printf("program -> functions"); }
		;

functions:  /* empty */ { printf("functions -> epsilon"); }
    | function functions { printf("functions -> function functions"); }
    ;

function:	FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY { printf("function -> FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY"); }
		;

declarations: /* empty */ { printf("declarations -> epsilon"); }
    | declaration declarations { printf("declarations -> declaration declarations"); }
    ;

declaration:  idents COLON ENUM L_PAREN idents R_PAREN { printf("declaration -> idents COLON ENUM L_PAREN idents R_PAREN"); }
    | idents COLON INTEGER { printf("declaration -> idents COLON INTEGER"); }
    | idents COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER { printf("declaration -> idents COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER"); }
    ;

statements: /* empty */ { printf("statements -> epsilon"); }
    | statement SEMICOLON statements { printf("statements -> statement SEMICOLON statements"); }
    ;

statement: var ASSIGN exp { printf("statement -> var ASSIGN exp"); }
    | IF bool_exp THEN statements ENDIF { printf("statement -> IF bool_exp THEN statements ENDIF"); }
    | IF bool_exp THEN statements ELSE statements ENDIF { printf("statement -> IF bool_exp THEN statements ELSE statements ENDIF"); }
    | WHILE bool_exp BEGINLOOP statements ENDLOOP { printf("statement -> WHILE bool_exp BEGINLOOP statements ENDLOOP"); }
    | DO BEGINLOOP statements ENDLOOP WHILE bool_exp { printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_exp"); }
    | READ vars { printf("statement -> READ vars"); }
    | WRITE vars { printf("statement -> WRITE vars"); }
    | CONTINUE { printf("statement -> CONTINUE"); }
    | RETURN exp { printf("statement -> RETURN exp"); }
    ;

bool_exp:  and_exp { printf("bool_exp -> and_exp"); }
    | and_exp OR bool_exp { printf("bool_exp -> and_exp OR bool_exp"); }
    ;

and_exp: relation_exp { printf("and_exp -> relation_exp"); }
	| relation_exp AND and_exp { printf("and_exp -> relation_exp AND and_exp"); }
	;


relation_exp: not_exp exp comp exp { printf("relation_exp -> not_exp exp comp exp"); }
    | not_exp TRUE { printf("relation_exp -> not_exp TRUE"); }
    | not_exp FALSE { printf("relation_exp -> not_exp FALSE"); }
    | not_exp L_PAREN bool_exp R_PAREN { printf("relation_exp -> not_exp L_PAREN bool_exp R_PAREN"); }
    ;

not_exp: /* empty */ { printf("not_exp -> epsilon"); }
	| NOT { printf("not_exp -> NOT"); }
	; 

comp: EQ { printf("comp -> EQ"); }
    | NEQ { printf("comp -> NEQ"); }
    | LT { printf("comp -> LT"); }
    | GT { printf("comp -> GT"); }
    | LTE { printf("comp -> LTE"); }
    | GTE { printf("comp -> GTE"); }
    ;

exps: /* empty */ { printf("exps -> epsilon"); }
    | exp COMMA exps { printf("exps -> exp COMMA exps"); }
    ;

exp:  multi_exp { printf("exp -> multi_exp"); }
    | multi_exp ADD exp { printf("exp -> multi_exp ADD exp"); }
    | multi_exp SUB exp { printf("exp -> multi_exp SUB exp"); }
    ;

multi_exp:  term { printf("multi_exp -> term"); }
    | term MULT multi_exp { printf("multi_exp -> term MULT multi_exp"); }
    | term DIV multi_exp { printf("multi_exp -> term DIV multi_exp"); }
    | term MOD multi_exp { printf("multi_exp -> term MOD multi_exp"); }
    ;

term: var { printf("term -> var"); }
    | NUMBER { printf("term -> NUMBER"); }
    | L_PAREN exp R_PAREN { printf("term -> L_PAREN exp R_PAREN"); }
    | SUB var { printf("term -> SUB var"); }
    | SUB NUMBER { printf("term -> SUB NUMBER"); }
    | SUB L_PAREN exp R_PAREN { printf("term -> SUB L_PAREN exp R_PAREN"); }
    | ident L_PAREN exps R_PAREN { printf("term -> ident L_PAREN exps R_PAREN"); }
    ;



vars: /* empty */ { printf("vars -> epsilon"); }
    | var COMMA vars { printf("vars -> var COMMA vars"); }
    ;

var: ident { printf("var -> ident"); }
    | ident L_SQUARE_BRACKET exp R_SQUARE_BRACKET { printf("var -> ident L_SQUARE_BRACKET exp R_SQUARE_BRACKET"); }
    ;

idents: /* empty */ { printf("idents -> epsilon"); }
    | ident COMMA idents { printf("idents -> ident COMMA idents"); }
    ;

ident:  IDENT IDENTIFIER { printf("ident -> IDENT %s", $2); }
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

