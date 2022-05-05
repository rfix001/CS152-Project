/* cs152-miniL phase1 */

%{
  int currLine = 1, currPos = 1;
%}

DIGIT [0-9]
ALPHA [a-zA-Z]
IDENTIFIER [a-zA-Z0-9_]

%%
"##"[^\n]*	{ /* Do nothing */  }
"function"	{currPos += yyleng; return FUNCTION;}
"beginparams"	{currPos += yyleng; return BEGIN_PARAMS;}
"endparams"	{currPos += yyleng; return END_PARAMS;}
"beginlocals"	{currPos += yyleng; return BEGIN_LOCALS;}
"endlocals"	{currPos += yyleng; return END_LOCALS;}
"beginbody"	{currPos += yyleng; return BEGIN_BODY;}
"endbody"	{currPos += yyleng; return END_BODY;}
"integer"	{currPos += yyleng; return INTEGER;}
"array"		{currPos += yyleng; return ARRAY;}	
"enum"		{currPos += yyleng; return ENUM;}
"of"		{currPos += yyleng; return OF;}
"if"		{currPos += yyleng; return IF;}
"then"		{currPos += yyleng; return THEN;}
"endif"		{currPos += yyleng; return ENDIF;}
"else"		{currPos += yyleng; return ELSE;}
"for"		{currPos += yyleng; return FOR;}
"while"		{currPos += yyleng; return WHILE;}
"do"		{currPos += yyleng; return DO;}
"beginloop"	{currPos += yyleng; return BEGINLOOP;}
"endloop"	{currPos += yyleng; return ENDLOOP;}
"continue"	{currPos += yyleng; return CONTINUE;}
"read"		{currPos += yyleng; return READ;}
"write"		{currPos += yyleng; return WRITE;}
"and"		{currPos += yyleng; return AND;}
"or"		{currPos += yyleng; return OR;}
"="            	{currPos += yyleng; return EQUAL;}
"+"            	{currPos += yyleng; return ADD;}
"-"            	{currPos += yyleng; return SUB;}
"*"            	{currPos += yyleng; return MULT;}
"/"            	{currPos += yyleng; return DIV;}
"("            	{currPos += yyleng; return L_PAREN;}
")"            	{currPos += yyleng; return R_PAREN;}

"not"           {currPos += yyleng; return NOT;}
"true"          {currPos += yyleng; return TRUE;}
"false"         {currPos += yyleng; return FALSE;}
"return"        {currPos += yyleng; return RETURN;}
[ \t]+          {/* ignore spaces */ currPos += yyleng;}
"\n"            {currLine++; currPos = 1;}
"%"             {currPos += yyleng; return MOD;}
"=="            {currPos += yyleng; return EQ;}
"<>"            {currPos += yyleng; return NEQ;}
"<"             {currPos += yyleng; return LT;}
">"             {currPos += yyleng; return GT;}
"<="            {currPos += yyleng; return LTE;}
">="            {currPos += yyleng; return GTE;}
";"             {currPos += yyleng; return SEMICOLON;}
":"             {currPos += yyleng; return COLON;}
","             {currPos += yyleng; return COMMA;}
"["             {currPos += yyleng; return L_SQUARE_BRACKET;}
"]"             {currPos += yyleng; return R_SQUARE_BRACKET;}
":="            {currPos += yyleng; return ASSIGN;}
{DIGIT}+     	{currPos += yyleng; return NUMBER;}
{DIGIT}+{IDENTIFIER}+       {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n",currLine, currPos, yytext); exit(0);}
{IDENTIFIER}+"_"{^IDENTIFIER}           {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n",currLine, currPos, yytext); exit(0);}
{ALPHA}+({DIGIT}|"_"|{ALPHA})*	{currPos += yyleng; return IDENT;}
.               {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n",currLine, currPos, yytext); exit(0);}
%%

int main(int argc, char ** argv)
{
  if(argc >= 2)
   {
      yyin = fopen(argv[1], "r");
      if(yyin == NULL)
      {
         yyin = stdin;
      }
   }
   else
   {
      yyin = stdin;
   }
   
   yylex();
}
