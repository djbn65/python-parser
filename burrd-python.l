/*    burrd-python.l

  PURPOSE: Recognizing Mini-Python Language
           Only a Simple Lexical Analyzer
  DESCR:   Just prints out what token type was found and the lexeme

  To create the syntax analyzer:

    flex example.l
    bison example.y
    g++ example.tab.c -o parser
    parser < inputFileName
*/

/* Defintions of regular expressions go here */

WSPACE		  [ \r\t]+
NEWLINE     [\n]

DIGIT       [0-9]
LETTER      [a-zA-Z]

IDENT			  ({LETTER}|_)({LETTER}|{DIGIT}|_)*
INTCONST    (\+|-)?{DIGIT}+
FLOATCONST  (\+|-)?{DIGIT}*\.{DIGIT}+
STRCONST    \"[^\"\n]*\"

COMMENT     #.*

%%

"if"          {
                // printTokenInfo("IF", yytext);
                return T_IF;
              }
"elif"        {
                // printTokenInfo("ELIF", yytext);
                return T_ELIF;
              }
"else"        {
                // printTokenInfo("ELSE", yytext);
                return T_ELSE;
              }
"while"       {
                // printTokenInfo("WHILE", yytext);
                return T_WHILE;
              }
"def"         {
                // printTokenInfo("DEF", yytext);
                return T_DEF;
              }
"for"         {
                // printTokenInfo("FOR", yytext);
                return T_FOR;
              }
"in"          {
                // printTokenInfo("IN", yytext);
                return T_IN;
              }
"break"       {
                // printTokenInfo("BREAK", yytext);
                return T_BREAK;
              }
"pass"        {
                // printTokenInfo("PASS", yytext);
                return T_PASS;
              }
"continue"    {
                // printTokenInfo("CONTINUE", yytext);
                return T_CONTINUE;
              }
"return"      {
                // printTokenInfo("RETURN", yytext);
                return T_RETURN;
              }
"end"         {
                // printTokenInfo("END", yytext);
                return T_END;
              }
"True"        {
                // printTokenInfo("TRUE", yytext);
                return T_TRUE;
              }
"False"       {
                // printTokenInfo("FALSE", yytext);
                return T_FALSE;
              }
"quit"        {
                // printTokenInfo("QUIT", yytext);
                return T_QUIT;
              }
"print"       {
                // printTokenInfo("PRINT", yytext);
                return T_PRINT;
              }
"raw_input"   {
                // printTokenInfo("INPUT", yytext);
                return T_READ;
              }
"list"        {
                // printTokenInfo("LIST", yytext);
                return T_LIST;
              }
"+"           {
                // printTokenInfo("ADD", yytext);
                return T_ADD;
              }
"-"           {
                // printTokenInfo("SUB", yytext);
                return T_SUB;
              }
"*"           {
                // printTokenInfo("MULT", yytext);
                return T_MULT;
              }
"/"           {
                // printTokenInfo("DIV", yytext);
                return T_DIV;
              }
"%"          {
                // printTokenInfo("MOD", yytext);
                return T_MOD;
              }
"**"          {
                // printTokenInfo("POWER", yytext);
                return T_POW;
              }
"<"           {
                // printTokenInfo("LT", yytext);
                return T_LT;
              }
">"           {
                // printTokenInfo("GT", yytext);
                return T_GT;
              }
"<="          {
                // printTokenInfo("LE", yytext);
                return T_LE;
              }
">="          {
                // printTokenInfo("GE", yytext);
                return T_GE;
              }
"=="          {
                // printTokenInfo("EQ", yytext);
                return T_EQ;
              }
"!="          {
                // printTokenInfo("NE", yytext);
                return T_NE;
              }
"not"         {
                // printTokenInfo("NOT", yytext);
                return T_NOT;
              }
"and"         {
                // printTokenInfo("AND", yytext);
                return T_AND;
              }
"or"          {
                // printTokenInfo("OR", yytext);
                return T_OR;
              }
"="           {
                // printTokenInfo("ASSIGN", yytext);
                return T_ASSIGN;
              }
"%="          {
                // printTokenInfo("MOD_EQ", yytext);
                return T_MODEQ;
              }
"/="          {
                // printTokenInfo("DIV_EQ", yytext);
                return T_DIVEQ;
              }
"-="          {
                // printTokenInfo("SUB_EQ", yytext);
                return T_SUBEQ;
              }
"+="          {
                // printTokenInfo("ADD_EQ", yytext);
                return T_ADDEQ;
              }
"*="          {
                // printTokenInfo("MULT_EQ", yytext);
                return T_MULTEQ;
              }
"**="         {
                // printTokenInfo("POW_EQ", yytext);
                return T_POWEQ;
              }
":"           {
                // printTokenInfo("COLON", yytext);
                return T_COLON;
              }
";"           {
                // printTokenInfo("SEMICOLON", yytext);
                return T_SEMICOLON;
              }
","           {
                // printTokenInfo("COMMA", yytext);
                return T_COMMA;
              }
"("           {
                // printTokenInfo("LPAREN", yytext);
                return T_LPAREN;
              }
")"           {
                // printTokenInfo("RPAREN", yytext);
                return T_RPAREN;
              }
"{"           {
                // printTokenInfo("LBRACE", yytext);
                return T_LBRACE;
              }
"}"           {
                // printTokenInfo("RBRACE", yytext);
                return T_RBRACE;
              }
"["           {
                // printTokenInfo("LBRACKET", yytext);
                return T_LBRACKET;
              }
"]"           {
                // printTokenInfo("RBRACKET", yytext);
                return T_RBRACKET;
              }
{COMMENT}     { }
{IDENT}       {
                yylval.text = strdup(yytext);
      				  // printTokenInfo("IDENT", yytext);
      				  return T_IDENT;
      			  }
{INTCONST}    {
                yylval.text = strdup(yytext);
      				  // printTokenInfo("INTCONST", yytext);
      				  return T_INTCONST;
      			  }
{FLOATCONST}  {
                yylval.text = strdup(yytext);  
                // printTokenInfo("FLOATCONST", yytext);
                return T_FLOATCONST;
              }
{STRCONST}    {
                yylval.text = strdup(yytext);
                // printTokenInfo("STRCONST", yytext);
                return T_STRCONST;
              }
{WSPACE}		  { }
{NEWLINE}     {
                numLines++;
                return T_NEWLINE;
              }
.			        {
        				// printTokenInfo("UNKNOWN", yytext);
        				return T_UNKNOWN;
        			}

%%