%{
  #include <stdio.h>
  #include <stdlib.h>
  void yyerror(const char *msg);
  extern int currLine;
  extern int currPos;
  FILE* yyin;
%}

%union{
  int ival;
}

%error-verbose
%start input
%token BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY ENUM OF IF THEN ENDIF ELSE FOR WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR EQUAL L_PAREN R_PAREN NOT TRUE FALSE RETURN EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN IDENT
%token <ival> NUMBER
%token <> IDENT
%type <dval> var exp term expseq expseq1 add_exp multi_exp
%left ADD SUB
%left MULT DIV MOD
%nonassoc UMINUS

%%
input:		/* empty */
		| input program
		;


program:	/* empty */
		| function program { $$ = $1 $2; }
		;

function:	function IDENT SEMICOLON BEGIN_PARAMS loop_dec END_PARAMS BEGIN_LOCALS loop_dec END_LOCALS BEGIN_BODY loop_state END_BODY { $$ = $1 $2 $5 $8 $11; }
		;

identseq:	IDENT { $$ = $1; }
		| IDENT COMMA identseq { $$ = $1 $3; }
		;

dec1:		ENUM L_PAREN identseq R_PAREN { $$ = $3; }
		| INTEGER
		| ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER { $$ = $3;  }
		;

dec:		identseq COLON dec1 { $$ = $1 $3 }
		;

else_state:	/* empty */
		|ELSE statement SEMICOLON else_state { $$ = $2 $4;}
		;

loop_state:	statement SEMICOLON { $$ = $1; }
		|statement SEMICOLON loop_state { $$ = $1 $3;  }
		;

varseq:		var { $$ = $1; }
		|var COMMA varseq { $$ = $1 $3; }
		;

statement:	var ASSIGN exp { $$ = $1 $3; }
		|IF bool_exp THEN statement SEMICOLON else_state ENDIF { $$ = $2 $4 $6; }
		|WHILE bool_exp BEGINLOOP loop_state ENDLOOP { $$ = $2 $4;}
		|DO BEGINLOOP loop_state ENDLOOP WHILE bool_exp { $$ = $3 $6; }
		|READ varseq { $$ = $2; }
		|WRITE varseq { $$ = $2; }
		|CONTINUE
		|RETURN exp { $$ = $2; }
		;

bool_exp:	and_exp { $$ = $1; }
		and_exp OR bool_exp { $$ = $1 $3; }
		;

and_exp:	relation_exp { $$ = $1; }
		|relation_exp AND and_exp { $$ = $1 $3 }
		;

not_exp:	/*empty*/
		|NOT
		;

relation_exp:	not_exp exp comp exp { $$ = $1 $2 $3 $4; }
		| not_exp TRUE { $$ = $1; }
		| not_exp FALSE { $$ = $1; }
		| not_exp L_PAREN bool_exp R_PAREN { $$ = $1 $3 }
		;

comp:		EQ { $$ = ==; }
		|NEQ { $$ = <>; }
		|LT { $$ = <; }
		|GT { $$ = >; }
		|LTE { $$ = <=; }
		|GTE { $$ = >=; }
		;

div_exp:	MULT term div_exp {$$ = * $2 $3; }
		| DIV term div_exp { $$ = / $2 $3; }
		| MOD term div_exp { $$ = % $2 $3; }
		;

multi_exp:	term { $$ = $1; }
		| term div_exp { $$ = $1 $2; }
		;

add_exp:	ADD multi_exp add_exp { $$ = + $2 $3; }
		| SUB multi_exp add_exp { $$ = - $2 $3; }
		;

exp:		multi_exp { $$ = $1; }
		| multi_exp add_exp { $$ = $1 $2;  }
		;

expseq:		/* empty */
		| expseq1 {$$ = $1;}
		;

expseq1: 	exp {$$ = $1;}
		| expseq1 COMMA exp {$$ = $1, $3;}
		;

term:		NUMBER { $$ = $1; }
		| SUB NUMBER %prec UMINUS { $$ = -$2; }
		| var { $$ = $1; }
		| SUB var %prec UMINUS { $$ = -$2; }
		| L_PAREN exp R_PAREN { $$ = $2; }
		| SUB L_PAREN exp R_PAREN %prec UMINUS { $$ = -$3; }
		| IDENT L_PAREN expseq R_PAREN { $$ = $1 $3; }
		;

var:		IDENT { $$ = $1; }
		| IDENT L_SQUARE_BRACKET exp R_SQUARE_BRACKET { $$ = $1 $3; }
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
