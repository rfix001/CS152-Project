%{
  #include <stdio.h>
  #include <stdlib.h>
  void yyerror(const char *msg);
  extern int currLine;
  extern int currPos;
  FILE* yyin;
%}

%error-verbose
%start input
%token 
%token <dval> NUMBER
%type <dval> exp

%%
input:		| input line
		;
