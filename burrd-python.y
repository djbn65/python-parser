%{
#include <stdio.h>
#include <stack>
#include <iostream>
#include "SymbolTable.h"
using namespace std;

stack<SYMBOL_TABLE> ScopeStack;

int numLines = 1;

void printRule(const char *, const char *);
int yyerror(const char *s);
void printTokenInfo(const char* tokenType, const char* lexeme);
void beginScope();
void endScope();
bool findEntryInAnyScope(const std::string theName);
TYPE_INFO& findEntryInAnyScopeTYPE(const std::string theName);

extern "C"
{
    int yyparse(void);
    int yylex(void);
    int yywrap() { return 1; }
}

%}

%union
{
  char* text;
  TYPE_INFO typeInfo;
};

%token T_IF T_WHILE T_FOR T_IN T_BREAK T_TRUE T_FALSE T_QUIT T_PRINT
%token T_READ T_LIST T_ADD T_SUB T_MULT T_DIV T_MOD T_POW T_LT T_GT T_LE T_GE 
%token T_EQ T_NE T_NOT T_AND T_OR T_ASSIGN T_COLON T_COMMA T_LPAREN T_LBRACE
%token T_RBRACE T_LBRACKET T_RBRACKET T_IDENT T_INTCONST T_FLOATCONST T_STRCONST 
%token T_UNKNOWN T_ELIF T_ELSE T_DEF T_RPAREN T_PASS T_SEMICOLON T_CONTINUE T_RETURN T_END T_NEWLINE
%token T_MODEQ T_DIVEQ T_SUBEQ T_ADDEQ T_MULTEQ T_POWEQ
%type <text> T_IDENT

%start N_START

%%

N_START           : N_PROGRAM
                    {
                      printRule("N_PROGRAM", "N_START");
                      printf("\n\n----Completed Parsing----\n\n");
                    }
                  | T_NEWLINE N_START
                    {
                      printRule("T_NEWLINE N_START", "N_START");
                    }
                  | /* epsilon */
                    {
                      printRule("EPSILON", "N_START");
                    }
                  ;
N_PROGRAM         : N_EXPR N_EXPR_LIST
                    {
                      printRule("N_EXPR N_EXPR_LIST", "N_PROGRAM");
                    }
                  ;
N_EXPR            : N_IF_EXPR
                    {
                      printRule("N_IF_EXPR", "N_EXPR");
                    }
                  | N_WHILE_EXPR
                    {
                      printRule("N_WHILE_EXPR", "N_EXPR");
                    }
                  | N_FOR_EXPR
                    {
                      printRule("N_FOR_EXPR", "N_EXPR");
                    }
                  | N_ASSIGNMENT_EXPR
                    {
                      printRule("N_ASSIGNMENT_EXPR", "N_EXPR");
                    }
                  | N_INPUT_EXPR
                    {
                      printRule("N_INPUT_EXPR", "N_EXPR");
                    }
                  | N_ARITHLOGIC_EXPR
                    {
                      printRule("N_ARITHLOGIC_EXPR", "N_EXPR");
                    }
                  | N_OUTPUT_EXPR
                    {
                      printRule("N_OUTPUT_EXPR", "N_EXPR");
                    }
                  | N_FUNCTION_DEF
                    {
                      printRule("N_FUNCTION_DEF", "N_EXPR");
                    }
                  | N_LIST_EXPR
                    {
                      printRule("N_LIST_EXPR", "N_EXPR");
                    }
                  | N_DICT_EXPR
                    {
                      printRule("N_DICT_EXPR", "N_EXPR");
                    }
                  | N_FUNCTION_CALL
                    {
                      printRule("N_FUNCTION_CALL", "N_EXPR");
                    }
                  | N_QUIT_EXPR
                    {
                      printRule("N_QUIT_EXPR", "N_EXPR");
                    }
                  ;
N_VALID_ASSIGN_EXPR : N_INPUT_EXPR
                      {
                        printRule("N_INPUT_EXPR", "N_VALID_ASSIGN_EXPR");
                      }
                    | N_ARITHLOGIC_EXPR
                      {
                        printRule("N_ARITHLOGIC_EXPR", "N_VALID_ASSIGN_EXPR");
                      }
                    | N_LIST_EXPR
                      {
                        printRule("N_LIST_EXPR", "N_VALID_ASSIGN_EXPR");
                      }
                    | N_DICT_EXPR
                      {
                        printRule("N_DICT_EXPR", "N_VALID_ASSIGN_EXPR");
                      }
                    | N_FUNCTION_CALL
                      {
                        printRule("N_FUNCTION_CALL", "N_VALID_ASSIGN_EXPR");
                      }
                    | N_ASSIGNMENT_EXPR
                      {
                        printRule("N_ASSIGNMENT_EXPR", "N_VALID_ASSIGN_EXPR");
                      }
                    ;
N_EXPR_LIST       : T_NEWLINE N_EXPR N_EXPR_LIST
                    {
                      printRule("T_NEWLINE N_EXPR N_EXPR_LIST", "N_EXPR_LIST");
                    }
                  | T_NEWLINE N_EXPR_LIST
                    {
                      printRule("T_NEWLINE", "N_EXPR_LIST");
                    }
                  | /* epsilon */
                    {
                      printRule("EPSILON", "N_EXPR_LIST");
                    }
                  ;
N_FUNC_EXPR_LIST  : T_NEWLINE N_EXPR N_FUNC_EXPR_LIST
                    {
                      printRule("T_NEWLINE N_EXPR N_FUNC_EXPR_LIST", "N_FUNC_EXPR_LIST");
                    }
                  | T_NEWLINE N_RETURN_EXPR N_FUNC_EXPR_LIST
                    {
                      printRule("T_NEWLINE N_RETURN_EXPR N_FUNC_EXPR_LIST", "N_FUNC_EXPR_LIST");
                    }
                  | T_NEWLINE N_FUNC_EXPR_LIST
                    {
                      printRule("T_NEWLINE N_FUNC_EXPR_LIST", "N_FUNC_EXPR_LIST");
                    }
                  | /* epsilon */
                    {
                      printRule("EPSILON", "N_FUNC_EXPR_LIST");
                    }
                  ;
N_RETURN_EXPR     : T_RETURN N_EXPR
                    {
                      printRule("T_RETURN N_EXPR", "N_RETURN_EXPR");
                    }
                  ;
N_CONST           : T_INTCONST
                    {
                      printRule("T_INTCONST", "N_CONST");
                    }
                  | T_STRCONST
                    {
                      printRule("T_STRCONST", "N_CONST");
                    }
                  | T_FLOATCONST
                    {
                      printRule("T_FLOATCONST", "N_CONST");
                    }
                  | T_TRUE
                    {
                      printRule("T_TRUE", "N_CONST");
                    }
                  | T_FALSE
                    {
                      printRule("T_FALSE", "N_CONST");
                    }
                  ;
N_IF_EXPR         : T_IF N_EXPR T_COLON N_EXPR_LIST N_OPT_ELIF N_OPT_ELSE T_END
                    {
                      printRule("T_IF N_EXPR T_COLON N_EXPR_LIST T_END", "N_IF_EXPR");
                    }
                  ;
N_OPT_ELIF        : T_ELIF N_EXPR T_COLON N_EXPR_LIST N_OPT_ELIF
                    {
                      printRule("T_ELIF N_EXPR T_COLON N_EXPR_LIST N_OPT_ELIF", "N_OPT_ELIF");
                    }
                  | /* epsilon */
                    {
                      printRule("EPSILON", "N_OPT_ELIF");
                    }
                  ;
N_OPT_ELSE        : T_ELSE T_COLON N_EXPR_LIST
                    {
                      printRule("T_ELSE T_COLON N_EXPR_LIST", "N_OPT_ELSE");
                    }
                  | /* epsilon */
                    {
                      printRule("EPSILON", "N_OPT_ELSE");
                    }
                  ;
N_WHILE_EXPR      : T_WHILE N_EXPR T_COLON N_EXPR_LIST T_END
                    {
                      printRule("T_WHILE N_EXPR T_COLON N_EXPR_LIST T_END", "N_WHILE_EXPR");
                    }
                  ;
N_FOR_EXPR        : T_FOR T_IDENT T_IN N_EXPR T_COLON N_EXPR_LIST T_END
                    {
                      printRule("T_FOR T_IDENT T_IN N_EXPR T_COLON N_EXPR_LIST T_END", "N_FOR_EXPR");
                    }
                  ;
N_ASSIGNMENT_EXPR : T_IDENT N_INDEX N_ASSIGN_OP N_VALID_ASSIGN_EXPR
                    {
                      printRule("T_IDENT T_ASSIGN N_EXPR", "N_ASSIGNMENT_EXPR");
                    }
                  ;
N_INDEX           : T_LBRACKET N_EXPR T_RBRACKET
                    {
                      printRule("T_LBRACKET N_EXPR T_RBRACKET", "N_INDEX");
                    }
                  | /* epsilon */
                    {
                      printRule("EPSILON", "N_INDEX");
                    }
                  ;
N_INPUT_EXPR      : T_READ T_LPAREN T_RPAREN
                    {
                      printRule("T_READ T_LPAREN T_RPAREN", "N_INPUT_EXPR");
                    }
                  ;
N_OUTPUT_EXPR     : T_PRINT N_EXPR
                    {
                      printRule("T_PRINT N_EXPR", "N_OUTPUT_EXPR");
                    }
                  | T_PRINT
                  ;
N_FUNCTION_DEF    : T_DEF T_IDENT T_LPAREN N_PARAM_LIST T_RPAREN T_COLON N_FUNC_EXPR_LIST T_END
                    {
                      printRule("T_DEF T_IDENT T_LPAREN N_PARAM_LIST T_RPAREN T_COLON N_FUNC_EXPR_LIST T_END", "N_FUNCTION_DEF");
                    }
                  ;
N_PARAM_LIST      : N_PARAMS
                    {
                      printRule("N_PARAMS", "N_PARAM_LIST");
                    }
                  | N_NO_PARAMS
                    {
                      printRule("N_NO_PARAMS", "N_PARAM_LIST");
                    }
                  ;
N_NO_PARAMS       : /* epsilon */
                    {
                      printRule("EPSILON", "N_NO_PARAMS");
                    }
                  ;
N_PARAMS          : T_IDENT
                    {
                      printRule("T_IDENT", "N_PARAMS");
                    }
                  | T_IDENT T_COMMA N_PARAMS
                    {
                      printRule("T_IDENT T_COMMA N_PARAMS", "N_PARAMS");
                    }
                  ;
N_LIST_EXPR       : T_LIST T_LPAREN N_CONST_LIST T_RPAREN
                    {
                      printRule("T_LIST T_LPAREN N_CONST_LIST T_RPAREN", "N_LIST_EXPR");
                    }
                  | T_LBRACKET N_CONST_LIST T_RBRACKET
                    {
                      printRule(" T_RBRACKET N_CONST_LIST T_LBRACKET", "N_LIST_EXPR");
                    }
                  ;
N_DICT_EXPR       : T_LBRACE N_DICT_CONST_LIST T_RBRACE
                    {
                      printRule("T_LBRACE N_DICT_CONST_LIST T_RBRACE", "N_DICT_EXPR");
                    }
                  ;
N_DICT_CONST_LIST : N_CONST T_COLON N_CONST T_COMMA N_DICT_CONST_LIST
                    {
                      printRule("N_CONST T_COLON N_CONST T_COMMA N_DICT_CONST_LIST", "N_DICT_CONST_LIST");
                    }
                  | N_CONST T_COLON N_CONST
                    {
                      printRule("N_CONST T_COLON N_CONST", "N_DICT_CONST_LIST");
                    }
                  ;
N_CONST_LIST      : N_CONST T_COMMA N_CONST_LIST
                    {
                      printRule("N_CONST T_COMMA N_CONST_LIST", "N_CONST_LIST");
                    }
                  | N_CONST
                    {
                      printRule("N_CONST", "N_CONST_LIST");
                    }
                  ;
N_FUNCTION_CALL   : T_IDENT T_LPAREN N_ARG_LIST T_RPAREN
                    {
                      printRule("T_IDENT T_LPAREN N_ARG_LIST T_RPAREN", "N_FUNCTION_CALL");
                    }
                  ;
N_ARG_LIST        : N_ARGS
                    {
                      printRule("N_ARGS", "N_ARG_LIST");
                    }
                  | N_NO_ARGS
                    {
                      printRule("N_NO_ARGS", "N_ARG_LIST");
                    }
                  ;
N_NO_ARGS         : /* epsilon */
                    {
                      printRule("EPSILON", "N_NO_ARGS");
                    }
                  ;
N_ARGS            : N_EXPR
                    {
                      printRule("N_EXPR", "N_ARGS");
                    }
                  | N_EXPR T_COMMA N_ARGS
                    {
                      printRule("N_EXPR T_COMMA N_ARGS", "N_ARGS");
                    }
                  ;
N_QUIT_EXPR       : T_QUIT T_LPAREN T_RPAREN
                    {
                      printRule("T_QUIT T_LPAREN T_RPAREN", "N_QUIT_EXPR");
                    }
                  ;
N_ARITHLOGIC_EXPR : N_SIMP_ARITHLOGIC
                    {
                      printRule("N_SIMP_ARITHLOGIC", "N_ARITHLOGIC_EXPR");
                    }
                  | N_SIMP_ARITHLOGIC N_REL_OP N_SIMP_ARITHLOGIC
                    {
                      printRule("N_SIMP_ARITHLOGIC N_REL_OP N_SIMP_ARITHLOGIC", "N_ARITHLOGIC_EXPR");
                    }
                  ;
N_SIMP_ARITHLOGIC : N_TERM N_ADD_OP_LIST
                    {
                      printRule("N_TERM N_ADD_OP_LIST", "N_SIMP_ARITHLOGIC");
                    }
                  ;
N_ADD_OP_LIST     : N_ADD_OP N_TERM N_ADD_OP_LIST
                    {
                      printRule("N_ADD_OP N_TERM N_ADD_OP_LIST", "N_ADD_OP_LIST");
                    }
                  | /* epsilon */
                    {
                      printRule("EPSILON", "N_ADD_OP_LIST");
                    }
                  ;
N_TERM            : N_FACTOR N_MULT_OP_LIST
                    {
                      printRule("N_FACTOR N_MULT_OP_LIST", "N_TERM");
                    }
                  ;
N_MULT_OP_LIST    : N_MULT_OP N_FACTOR N_MULT_OP_LIST
                    {
                      printRule("N_MULT_OP N_FACTOR N_MULT_OP_LIST", "N_MULT_OP_LIST");
                    }
                  | /* epsilon */
                    {
                      printRule("EPSILON", "N_MULT_OP_LIST");
                    }
                  ;
N_FACTOR          : N_VAR
                    {
                      printRule("N_VAR", "N_FACTOR");
                    }
                  | N_CONST
                    {
                      printRule("N_CONST", "N_FACTOR");
                    }
                  | T_LPAREN N_EXPR T_RPAREN
                    {
                      printRule("T_LPAREN N_EXPR T_RPAREN", "N_FACTOR");
                    }
                  | T_NOT N_FACTOR
                    {
                      printRule("T_NOT N_FACTOR", "N_FACTOR");
                    }
                  ;
N_ADD_OP          : T_ADD
                    {
                      printRule("T_ADD", "N_ADD_OP");
                    }
                  | T_SUB
                    {
                      printRule("T_SUB", "N_ADD_OP");
                    }
                  | T_OR
                    {
                      printRule("T_OR", "N_ADD_OP");
                    }
                  ;
N_MULT_OP         : T_MULT
                    {
                      printRule("T_MULT", "N_MULT_OP");
                    }
                  | T_DIV
                    {
                      printRule("T_DIV", "N_MULT_OP");
                    }
                  | T_AND
                    {
                      printRule("T_AND", "N_MULT_OP");
                    }
                  | T_MOD
                    {
                      printRule("T_MOD", "N_MULT_OP");
                    }
                  | T_POW
                    {
                      printRule("T_POW", "N_MULT_OP");
                    }
                  ;
N_REL_OP          : T_LT
                    {
                      printRule("T_LT", "N_REL_OP");
                    }
                  | T_GT
                    {
                      printRule("T_GT", "N_REL_OP");
                    }
                  | T_LE
                    {
                      printRule("T_LE", "N_REL_OP");
                    }
                  | T_GE
                    {
                      printRule("T_GE", "N_REL_OP");
                    }
                  | T_EQ
                    {
                      printRule("T_EQ", "N_REL_OP");
                    }
                  | T_NE
                    {
                      printRule("T_NE", "N_REL_OP");
                    }
                  ;
N_ASSIGN_OP       : T_ASSIGN
                    {
                      printRule("T_ASSIGN", "T_ASSIGN_OP");
                    }
                  | T_MODEQ
                    {
                      printRule("T_MODEQ", "T_ASSIGN_OP");
                    }
                  | T_DIVEQ
                    {
                      printRule("T_DIVEQ", "T_ASSIGN_OP");
                    }
                  | T_SUBEQ
                    {
                      printRule("T_SUBEQ", "T_ASSIGN_OP");
                    }
                  | T_ADDEQ
                    {
                    printRule("T_ADDEQ", "T_ASSIGN_OP");
                    }
                  | T_MULTEQ
                    {
                      printRule("T_MULTEQ", "T_ASSIGN_OP");
                    }
                  | T_POWEQ
                    {
                      printRule("T_POWEQ", "T_ASSIGN_OP");
                    }
                  ;
N_VAR             : N_ENTIRE_VAR
                    {
                      printRule("N_ENTIRE_VAR", "N_VAR");
                    }
                  | N_SINGLE_ELEMENT
                    {
                      printRule("N_SINGLE_ELEMENT", "N_VAR");
                    }
                  ;
N_SINGLE_ELEMENT  : T_IDENT T_LBRACKET N_EXPR T_RBRACKET
                    {
                      printRule("T_IDENT T_LBRACKET N_EXPR T_RBRACKET", "N_SINGLE_ELEMENT");
                    }
                  ;
N_ENTIRE_VAR      : T_IDENT
                    {
                      printRule("T_IDENT", "N_ENTIRE_VAR");
                    }
                  ;

%%

#include "lex.yy.c"
extern FILE *yyin;

void printRule(const char *lhs, const char *rhs)
{
  printf("%s -> %s\n", rhs, lhs);
  return;
}

int yyerror(const char *s)
{
  printf("Line %d: %s\n", numLines, s);
  exit(1);
}

void printTokenInfo(const char* tokenType, const char* lexeme)
{
  printf("TOKEN: %s  LEXEME: %s\n", tokenType, lexeme);
}

void beginScope()
{
  ScopeStack.push(SYMBOL_TABLE());
  printf("\n___Entering new scope...\n\n");
}

void endScope()
{
  ScopeStack.pop();
  printf("\n___Exiting scope...\n\n");
}

bool findEntryInAnyScope(const std::string theName)
{
  if (ScopeStack.empty()) return(false);
  bool found = ScopeStack.top( ).findEntry(theName).type != UNDEF;
  if (found)
    return(true);
  else { // check in "next higher"scope
    SYMBOL_TABLE symbolTable = ScopeStack.top( );
    ScopeStack.pop( );
    found = findEntryInAnyScope(theName);
    ScopeStack.push(symbolTable); // restore the stack
    return(found);
  }
}

TYPE_INFO& findEntryInAnyScopeTYPE(const std::string theName)
{
  if (ScopeStack.empty())
  {
    static TYPE_INFO temp;
    temp.type = UNDEF;
    temp.numParams = NOT_APPLICABLE;
    temp.returnType = NOT_APPLICABLE;
    temp.isFuncParam = false;
    return(temp);
  }
  static TYPE_INFO type;
  type = ScopeStack.top( ).findEntry(theName);
  if (type.type != UNDEF)
    return(type);
  else { // check in "next higher"scope
    SYMBOL_TABLE symbolTable = ScopeStack.top( );
    ScopeStack.pop( );
    type = findEntryInAnyScopeTYPE(theName);
    ScopeStack.push(symbolTable); // restore the stack
    return(type);
  }
}

int main()
{
  beginScope();
  do
  {
	  yyparse();
  } while (!feof(yyin));

  return(0);
}