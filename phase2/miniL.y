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
%token BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY ENUM OF IF THEN ENDIF ELSE FOR WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR EQUAL ADD SUB MULT DIV L_PAREN R_PAREN NOT TRUE FALSE RETURN MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token <ival> NUMBER
%type <dval> exp

%%
input:		| input line
		;
