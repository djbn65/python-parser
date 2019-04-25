%{
#include <stdio.h>
#include <stack>
#include <iostream>
#include <vector>
#include <iomanip>
#include <math.h>
#include "SymbolTable.h"
using namespace std;

stack<SYMBOL_TABLE> ScopeStack;

int numLines = 1;
vector<TYPE_INFO> metaList;
SYMBOL_TABLE* symPtr;

void printRule(const char *, const char *);
int yyerror(const char *s);
void printTokenInfo(const char* tokenType, const char* lexeme);
void beginScope();
void endScope();
bool findEntryInAnyScope(const std::string theName);
TYPE_INFO& findEntryInAnyScopeTYPE(const std::string theName);

void valueAssignment(void* leftValue, void* rightValue, int typeCode);
void printList(vector<TYPE_INFO> vec);
void outputValue(void const * const value, const int type);

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
%type <text> T_IDENT T_INTCONST T_FLOATCONST T_STRCONST;
%type <typeInfo> N_CONST N_EXPR N_EXPR_LIST N_WHILE_EXPR N_ARITHLOGIC_EXPR N_ASSIGNMENT_EXPR N_OUTPUT_EXPR N_INPUT_EXPR N_LIST_EXPR N_FUNCTION_CALL N_FUNCTION_DEF N_QUIT_EXPR N_INDEX N_SINGLE_ELEMENT N_ENTIRE_VAR N_TERM N_MULT_OP_LIST N_FACTOR N_ADD_OP N_MULT_OP N_VAR N_SIMP_ARITHLOGIC N_ADD_OP_LIST N_FOR_EXPR N_IF_EXPR  N_PARAM_LIST N_ARG_LIST N_ARGS N_VALID_ASSIGN_EXPR N_DICT_EXPR N_FUNC_EXPR_LIST N_PROGRAM N_VALID_PRINT_EXPR N_REL_OP N_PAREN_EXPR N_CONST_LIST N_IND_EXPR N_VALID_IF_EXPR;

%start N_START

%%

N_START           : N_PROGRAM
                    {
                      // printRule("N_PROGRAM", "N_START");
                      endScope();
                      printf("\n\n----Completed Parsing----\n\n");
                    }
                  | T_NEWLINE N_START
                    {
                      // printRule("T_NEWLINE N_START", "N_START");
                    }
                  | /* epsilon */
                    {
                      // printRule("EPSILON", "N_START");
                      endScope();
                    }
                  ;
N_PROGRAM         : N_EXPR N_EXPR_LIST
                    {
                      // printRule("N_EXPR N_EXPR_LIST", "N_PROGRAM");
                    }
                  ;
N_EXPR            : N_IF_EXPR
                    {
                      // printRule("N_IF_EXPR", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      valueAssignment($$.value, $1.value, $1.type);
                      cout << ">>> ";
                    }
                  | N_WHILE_EXPR
                    {
                      // printRule("N_WHILE_EXPR", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      valueAssignment($$.value, $1.value, $1.type);
                      cout << ">>> ";
                    }
                  | N_FOR_EXPR
                    {
                      // printRule("N_FOR_EXPR", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      valueAssignment($$.value, $1.value, $1.type);
                      cout << ">>> ";
                    }
                  | N_ASSIGNMENT_EXPR
                    {
                      // printRule("N_ASSIGNMENT_EXPR", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      valueAssignment($$.value, $1.value, $1.type);
                      cout << ">>> ";
                    }
                  | N_INPUT_EXPR
                    {
                      // printRule("N_INPUT_EXPR", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      valueAssignment($$.value, $1.value, $1.type);
                      cout << ">>> ";
                    }
                  | N_ARITHLOGIC_EXPR
                    {
                      // printRule("N_ARITHLOGIC_EXPR", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      valueAssignment($$.value, $1.value, $1.type);
                      outputValue($1.value, $1.type);
                      cout << ">>> ";
                    }
                  | N_OUTPUT_EXPR
                    {
                      // printRule("N_OUTPUT_EXPR", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      valueAssignment($$.value, $1.value, $1.type);
                      cout << ">>> ";
                    }
                  | N_FUNCTION_DEF
                    {
                      // printRule("N_FUNCTION_DEF", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      valueAssignment($$.value, $1.value, $1.type);
                      cout << ">>> ";
                    }
                  | N_LIST_EXPR
                    {
                      // printRule("N_LIST_EXPR", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      valueAssignment($$.value, $1.value, $1.type);
                      cout << ">>> ";
                    }
                  | N_DICT_EXPR
                    {
                      // printRule("N_DICT_EXPR", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      valueAssignment($$.value, $1.value, $1.type);
                      cout << ">>> ";
                    }
                  | N_FUNCTION_CALL
                    {
                      // printRule("N_FUNCTION_CALL", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      valueAssignment($$.value, $1.value, $1.type);
                      cout << ">>> ";
                    }
                  | N_QUIT_EXPR
                    {
                      // printRule("N_QUIT_EXPR", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                    }
                  ;
N_VALID_ASSIGN_EXPR : N_INPUT_EXPR
                      {
                        // printRule("N_INPUT_EXPR", "N_VALID_ASSIGN_EXPR");
                        $$.type = $1.type;
                        $$.numParams = $1.numParams;
                        $$.returnType = $1.returnType;
                        $$.isFuncParam = $1.isFuncParam;
                        valueAssignment($$.value, $1.value, $1.type);
                      }
                    | N_ARITHLOGIC_EXPR
                      {
                        // printRule("N_ARITHLOGIC_EXPR", "N_VALID_ASSIGN_EXPR");
                        $$.type = $1.type;
                        $$.numParams = $1.numParams;
                        $$.returnType = $1.returnType;
                        $$.isFuncParam = $1.isFuncParam;
                        valueAssignment($$.value, $1.value, $1.type);
                      }
                    | N_LIST_EXPR
                      {
                        // printRule("N_LIST_EXPR", "N_VALID_ASSIGN_EXPR");
                        $$.type = $1.type;
                        $$.numParams = $1.numParams;
                        $$.returnType = $1.returnType;
                        $$.isFuncParam = $1.isFuncParam;
                        valueAssignment($$.value, $1.value, $1.type);
                      }
                    | N_DICT_EXPR
                      {
                        // printRule("N_DICT_EXPR", "N_VALID_ASSIGN_EXPR");
                        $$.type = $1.type;
                        $$.numParams = $1.numParams;
                        $$.returnType = $1.returnType;
                        $$.isFuncParam = $1.isFuncParam;
                        valueAssignment($$.value, $1.value, $1.type);
                      }
                    | N_FUNCTION_CALL
                      {
                        // printRule("N_FUNCTION_CALL", "N_VALID_ASSIGN_EXPR");
                        $$.type = $1.type;
                        $$.numParams = $1.numParams;
                        $$.returnType = $1.returnType;
                        $$.isFuncParam = $1.isFuncParam;
                        valueAssignment($$.value, $1.value, $1.type);
                      }
                    | N_ASSIGNMENT_EXPR
                      {
                        // printRule("N_ASSIGNMENT_EXPR", "N_VALID_ASSIGN_EXPR");
                        $$.type = $1.type;
                        $$.numParams = $1.numParams;
                        $$.returnType = $1.returnType;
                        $$.isFuncParam = $1.isFuncParam;
                        valueAssignment($$.value, $1.value, $1.type);
                      }
                    ;
N_VALID_PRINT_EXPR  : N_INPUT_EXPR
                      {
                        $$.type = $1.type;
                        valueAssignment($$.value, $1.value, $1.type);
                      }
                    | N_ARITHLOGIC_EXPR
                      {
                        $$.type = $1.type;
                        valueAssignment($$.value, $1.value, $1.type);
                      }
                    | N_LIST_EXPR
                      {
                        $$.type = $1.type;
                        valueAssignment($$.value, $1.value, $1.type);
                      }
                    | N_DICT_EXPR
                      {
                        $$.type = $1.type;
                        valueAssignment($$.value, $1.value, $1.type);
                      }
                    | N_FUNCTION_CALL
                      {
                        $$.type = $1.type;
                        valueAssignment($$.value, $1.value, $1.type);
                      }
                    ;
N_EXPR_LIST       : T_NEWLINE N_EXPR N_EXPR_LIST
                    {
                      // printRule("T_NEWLINE N_EXPR N_EXPR_LIST", "N_EXPR_LIST");
                    }
                  | T_NEWLINE N_EXPR_LIST
                    {
                      // printRule("T_NEWLINE", "N_EXPR_LIST");
                    }
                  | /* epsilon */
                    {
                      // printRule("EPSILON", "N_EXPR_LIST");
                    }
                  ;
N_FUNC_EXPR_LIST  : T_NEWLINE N_EXPR N_FUNC_EXPR_LIST
                    {
                      // printRule("T_NEWLINE N_EXPR N_FUNC_EXPR_LIST", "N_FUNC_EXPR_LIST");
                    }
                  | T_NEWLINE N_RETURN_EXPR T_NEWLINE
                    {
                      // printRule("T_NEWLINE N_RETURN_EXPR N_FUNC_EXPR_LIST", "N_FUNC_EXPR_LIST");
                    }
                  | T_NEWLINE N_FUNC_EXPR_LIST
                    {
                      // printRule("T_NEWLINE N_FUNC_EXPR_LIST", "N_FUNC_EXPR_LIST");
                    }
                  | /* epsilon */
                    {
                      // printRule("EPSILON", "N_FUNC_EXPR_LIST");
                    }
                  ;
N_RETURN_EXPR     : T_RETURN N_EXPR
                    {
                      // printRule("T_RETURN N_EXPR", "N_RETURN_EXPR");
                    }
                  ;
N_CONST           : T_INTCONST
                    {
                      // printRule("T_INTCONST", "N_CONST");
                      $$.type = INT;
                      $$.numParams = NOT_APPLICABLE;
                      $$.returnType = NOT_APPLICABLE;
                      $$.value = new int(atoi($1));
                    }
                  | T_STRCONST
                    {
                      // printRule("T_STRCONST", "N_CONST");
                      $$.type = STR;
                      $$.numParams = NOT_APPLICABLE;
                      $$.returnType = NOT_APPLICABLE;
                      $$.value = new string($1);
                    }
                  | T_FLOATCONST
                    {
                      // printRule("T_FLOATCONST", "N_CONST");
                      $$.type = FLOAT;
                      $$.numParams = NOT_APPLICABLE;
                      $$.returnType = NOT_APPLICABLE;
                      $$.value = new float(atof($1));
                    }
                  | T_TRUE
                    {
                      // printRule("T_TRUE", "N_CONST");
                      $$.type = BOOL;
                      $$.numParams = NOT_APPLICABLE;
                      $$.returnType = NOT_APPLICABLE;
                      $$.value = new bool(true);
                    }
                  | T_FALSE
                    {
                      // printRule("T_FALSE", "N_CONST");
                      $$.type = BOOL;
                      $$.numParams = NOT_APPLICABLE;
                      $$.returnType = NOT_APPLICABLE;
                      $$.value = new bool(false);
                    }
                  ;
N_IF_EXPR         : T_IF N_VALID_IF_EXPR T_COLON
                    {
                      cout << "... ";
                    }
                    N_IF_EXPR_LIST N_OPT_ELIF N_OPT_ELSE T_END
                    {
                      // printRule("T_IF N_EXPR T_COLON N_EXPR_LIST T_END", "N_IF_EXPR");
                      
                    }
                  ;
N_VALID_IF_EXPR   : N_ARITHLOGIC_EXPR
                    {
                      $$.type = $1.type;
                      valueAssignment($$.value, $1.value, $1.type);
                    }
                  | N_LIST_EXPR
                    {
                      $$.type = BOOL;
                      if ((*(vector<TYPE_INFO>*)($1.value)).size() == 0)
                        $$.value = new bool(false);
                      else
                        $$.value = new bool(true);
                    }
                  | N_DICT_EXPR
                    {
                      $$.type = $1.type;
                      valueAssignment($$.value, $1.value, $1.type);
                    }
                  | N_QUIT_EXPR
                  ;
N_IF_EXPR_LIST    : T_NEWLINE N_IF_BODY_EXPR N_IF_EXPR_LIST
                  | T_NEWLINE N_IF_EXPR_LIST
                  | /* epsilon */
                  ;
N_IF_BODY_EXPR    : N_IF_EXPR
                    {
                      cout << "... ";
                    }
                  | N_WHILE_EXPR
                    {
                      cout << "... ";
                    }
                  | N_FOR_EXPR
                    {
                      cout << "... ";
                    }
                  | N_ARITHLOGIC_EXPR
                    {
                      cout << "... ";
                    }
                  | N_ASSIGNMENT_EXPR
                    {
                      cout << "... ";
                    }
                  | N_OUTPUT_EXPR
                    {
                      cout << "... ";
                    }
                  | N_INPUT_EXPR
                    {
                      cout << "... ";
                    }
                  | N_LIST_EXPR
                    {
                      cout << "... ";
                    }
                  | N_DICT_EXPR
                    {
                      cout << "... ";
                    }
                  | N_FUNCTION_CALL
                    {
                      cout << "... ";
                    }
                  | N_QUIT_EXPR
                  ;
N_OPT_ELIF        : T_ELIF N_EXPR T_COLON N_EXPR_LIST N_OPT_ELIF
                    {
                      // printRule("T_ELIF N_EXPR T_COLON N_EXPR_LIST N_OPT_ELIF", "N_OPT_ELIF");
                    }
                  | /* epsilon */
                    {
                      // printRule("EPSILON", "N_OPT_ELIF");
                    }
                  ;
N_OPT_ELSE        : T_ELSE T_COLON N_EXPR_LIST
                    {
                      // printRule("T_ELSE T_COLON N_EXPR_LIST", "N_OPT_ELSE");
                    }
                  | /* epsilon */
                    {
                      // printRule("EPSILON", "N_OPT_ELSE");
                    }
                  ;
N_WHILE_EXPR      : T_WHILE N_EXPR T_COLON N_EXPR_LIST T_END
                    {
                      // printRule("T_WHILE N_EXPR T_COLON N_EXPR_LIST T_END", "N_WHILE_EXPR");
                    }
                  ;
N_FOR_EXPR        : T_FOR T_IDENT
                    {
                      int tempType = ScopeStack.top().findEntry($2).type;
                      if (tempType == UNDEF)
                      {
                        printf("___Adding %s to symbol table\n", $2);
                        TYPE_INFO temp;
                        temp.type = INT;
                        temp.numParams = NOT_APPLICABLE;
                        temp.returnType = NOT_APPLICABLE;
                        temp.isFuncParam = false;
                        ScopeStack.top().addEntry(SYMBOL_TABLE_ENTRY($2, temp));
                      }
                    } 
                    T_IN N_EXPR T_COLON N_EXPR_LIST T_END
                    {
                      // printRule("T_FOR T_IDENT T_IN N_EXPR T_COLON N_EXPR_LIST T_END", "N_FOR_EXPR");
                    }
                  ;
N_ASSIGNMENT_EXPR : T_IDENT N_INDEX 
                    {
                      // printRule("ASSIGNMENT_EXPR", "IDENT INDEX ASSIGN EXPR");
                      if ($2.type == INDEXTYPE)
                      {
                        if (!findEntryInAnyScope($1))
                          yyerror("Undefined identifier");
                        else if (findEntryInAnyScopeTYPE($1).type != LIST)
                          yyerror("Arg 1 must be list");
                      }
                      else
                      {
                        if (ScopeStack.top().findEntry($1).type == UNDEF)
                        {
                          TYPE_INFO temp;
                          temp.type = UNDEF;
                          temp.numParams = NOT_APPLICABLE;
                          temp.returnType = NOT_APPLICABLE;
                          temp.isFuncParam = false;
                          ScopeStack.top().addEntry(SYMBOL_TABLE_ENTRY($1, temp));
                        }
                      }
                    }
                    N_ASSIGN_OP N_VALID_ASSIGN_EXPR
                    {
                      if (findEntryInAnyScopeTYPE($1).isFuncParam && $5.type != INT && $5.type != BOOL)
                        yyerror("Arg 1 must be integer");
                      $$.type = $5.type;
                      $$.numParams = $5.numParams;
                      $$.returnType = $5.returnType;
                      if ($2.type == INDEXTYPE)
                      {
                        int size = (*(vector<TYPE_INFO>*)(findEntryInAnyScopeTYPE($1).value)).size();
                        if ($5.type == LIST)
                          yyerror("Arg 1 cannot be list");
                        if (*(int*)($2.value) < -size ||
                            *(int*)($2.value) >= size)
                          yyerror("Subscript out of bounds");
                        if ($5.type == STR)
                        {
                          if ((*(int*)($2.value)) < 0)
                          {
                            (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry($1).value))[(*(int*)($2.value)) + size].value = new std::string(*(std::string*)($5.value));
                            $$.value = new std::string(*(std::string*)($5.value));
                            (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry($1).value))[(*(int*)($2.value)) + size].type = $5.type;
                          }
                          else
                          {
                            (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry($1).value))[(*(int*)($2.value))].value = new std::string(*(std::string*)($5.value));
                            $$.value = new std::string(*(std::string*)($5.value));
                            (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry($1).value))[(*(int*)($2.value))].type = $5.type;
                          }
                        }
                        else if ($5.type == INT)
                        {
                          if ((*(int*)($2.value)) < 0)
                          {
                            (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry($1).value))[(*(int*)($2.value)) + size].value = new int(*(int*)($5.value));
                            (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry($1).value))[(*(int*)($2.value)) + size].type = $5.type;
                            $$.value = new int(*(int*)($5.value));
                          }
                          else
                          {
                            (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry($1).value))[(*(int*)($2.value))].value = new int(*(int*)($5.value));
                            (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry($1).value))[(*(int*)($2.value))].type = $5.type;
                            $$.value = new int(*(int*)($5.value));
                          }
                        }
                        else if ($5.type == FLOAT)
                        {
                          if ((*(int*)($2.value)) < 0)
                          {
                            (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry($1).value))[(*(int*)($2.value)) + size].value = new float(*(float*)($5.value));
                            (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry($1).value))[(*(int*)($2.value)) + size].type = $5.type;
                            $$.value = new float(*(float*)($5.value));
                          }
                          else
                          {
                            (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry($1).value))[(*(int*)($2.value))].value = new float(*(float*)($5.value));
                            (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry($1).value))[(*(int*)($2.value))].type = $5.type;
                            $$.value = new float(*(float*)($5.value));
                          }
                        }
                        else if ($5.type == BOOL)
                        {
                          if ((*(int*)($2.value)) < 0)
                          {
                            (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry($1).value))[(*(int*)($2.value)) + size].value = new bool(*(bool*)($5.value));
                            (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry($1).value))[(*(int*)($2.value)) + size].type = $5.type;
                            $$.value = new bool(*(bool*)($5.value));
                          }
                          else
                          {
                            (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry($1).value))[(*(int*)($2.value))].value = new bool(*(bool*)($5.value));
                            (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry($1).value))[(*(int*)($2.value))].type = $5.type;
                            $$.value = new bool(*(bool*)($5.value));
                          }
                        }
                      }
                      else
                      {
                        ScopeStack.top().findEntry($1).type = $5.type;
                        ScopeStack.top().findEntry($1).numParams = $5.numParams;
                        ScopeStack.top().findEntry($1).returnType = $5.returnType;
                        ScopeStack.top().findEntry($1).isFuncParam = $5.isFuncParam;
                        if ($5.type == STR)
                        {
                          ScopeStack.top().findEntry($1).value = new std::string(*(std::string*)($5.value));
                          $$.value = new std::string(*(std::string*)($5.value));
                        }
                        else if ($5.type == INT)
                        {
                          ScopeStack.top().findEntry($1).value = new int(*(int*)($5.value));
                          $$.value = new int(*(int*)($5.value));
                        }
                        else if ($5.type == FLOAT)
                        {
                          ScopeStack.top().findEntry($1).value = new float(*(float*)($5.value));
                          $$.value = new float(*(float*)($5.value));
                        }
                        else if ($5.type == BOOL)
                        {
                          ScopeStack.top().findEntry($1).value = new bool(*(bool*)($5.value));
                          $$.value = new bool(*(bool*)($5.value));
                        }
                        else if ($5.type == LIST)
                        {
                          ScopeStack.top().findEntry($1).value = new vector<TYPE_INFO>(*(vector<TYPE_INFO>*)($5.value));
                          $$.value = new vector<TYPE_INFO>(*(vector<TYPE_INFO>*)($5.value));
                        }
                      }
                    }
                  ;
N_INDEX           : T_LBRACKET N_IND_EXPR T_RBRACKET
                    {
                      // printRule("T_LBRACKET N_EXPR T_RBRACKET", "N_INDEX");
                      $$.type = INDEXTYPE;
                      $$.value = new int(*(int*)($2.value));
                    }
                  | /* epsilon */
                    {
                      // printRule("EPSILON", "N_INDEX");
                      $$.type = UNDEF;
                    }
                  ;
N_IND_EXPR        : N_ARITHLOGIC_EXPR
                    {
                      $$.type = $1.type;
                      valueAssignment($$.value, $1.value, $1.type);
                    }
                  | N_INPUT_EXPR
                    {
                      $$.type = $1.type;
                      valueAssignment($$.value, $1.value, $1.type);
                    }
                  ;
N_INPUT_EXPR      : T_READ T_LPAREN T_RPAREN
                    {
                      // printRule("T_READ T_LPAREN T_RPAREN", "N_INPUT_EXPR");
                      string input;
                      getline(cin, input);
                      $$.value = new string(input);
                      $$.type = STR;
                    }
                  ;
N_OUTPUT_EXPR     : T_PRINT N_VALID_PRINT_EXPR
                    {
                      // printRule("T_PRINT N_VALID_PRINT_EXPR", "N_OUTPUT_EXPR");
                      outputValue($2.value, $2.type);
                    }
                  | T_PRINT
                    {
                      // printRule("T_PRINT", "N_OUTPUT_EXPR");
                      cout << "\n";
                    }
                  ;
N_FUNCTION_DEF    : T_DEF T_IDENT
                    {
                      symPtr = &ScopeStack.top();
                    }
                    T_LPAREN
                    {
                      beginScope();
                    }
                    N_PARAM_LIST
                    {
                      $6.numParams = ScopeStack.top().size();
                    } 
                    T_RPAREN T_COLON N_FUNC_EXPR_LIST T_END
                    {
                      // printRule("T_DEF T_IDENT T_LPAREN N_PARAM_LIST T_RPAREN T_COLON N_FUNC_EXPR_LIST T_END", "N_FUNCTION_DEF");
                      if ($10.type == FUNCTION)
                        yyerror("Arg 2 cannot be function");
                      $$.type = FUNCTION;
                      $$.numParams = $6.numParams;
                      $$.returnType = $10.type;
                      if (symPtr != NULL)
                      {
                        if (symPtr->findEntry($2).type != UNDEF)
                        {
                          symPtr->findEntry($2).type = FUNCTION;
                          symPtr->findEntry($2).numParams = $6.numParams;
                          symPtr->findEntry($2).returnType = $10.type;
                          symPtr->findEntry($2).isFuncParam = false;
                        }
                        else
                        {
                          TYPE_INFO temp;
                          temp.type = FUNCTION;
                          temp.numParams = $6.numParams;
                          temp.returnType = $10.type;
                          temp.isFuncParam = false;
                          symPtr->addEntry(SYMBOL_TABLE_ENTRY($2, temp));
                        }
                      }
                      endScope();
                    }
                  ;
N_PARAM_LIST      : N_PARAMS
                    {
                      // printRule("N_PARAMS", "N_PARAM_LIST");
                    }
                  | N_NO_PARAMS
                    {
                      // printRule("N_NO_PARAMS", "N_PARAM_LIST");
                    }
                  ;
N_NO_PARAMS       : /* epsilon */
                    {
                      // printRule("EPSILON", "N_NO_PARAMS");
                    }
                  ;
N_PARAMS          : T_IDENT
                    {
                      // printRule("T_IDENT", "N_PARAMS");
                      if (ScopeStack.top().findEntry($1).type == UNDEF)
                      {
                        TYPE_INFO temp;
                        temp.type = INT;
                        temp.numParams = NOT_APPLICABLE;
                        temp.returnType = NOT_APPLICABLE;
                        temp.isFuncParam = true;
                        ScopeStack.top().addEntry(SYMBOL_TABLE_ENTRY($1, temp));
                      }
                      else if (ScopeStack.top().findEntry($1).type != UNDEF)
                        yyerror("Multiply defined identifier");
                    }
                  | T_IDENT T_COMMA N_PARAMS
                    {
                      // printRule("T_IDENT T_COMMA N_PARAMS", "N_PARAMS");
                      if (ScopeStack.top().findEntry($1).type == UNDEF)
                      {
                        TYPE_INFO temp;
                        temp.type = INT;
                        temp.numParams = NOT_APPLICABLE;
                        temp.returnType = NOT_APPLICABLE;
                        temp.isFuncParam = true;
                        ScopeStack.top().addEntry(SYMBOL_TABLE_ENTRY($1, temp));
                      }
                      else if (ScopeStack.top().findEntry($1).type != UNDEF)
                        yyerror("Multiply defined identifier");
                    }
                  ;
N_LIST_EXPR       : T_LIST T_LPAREN N_CONST_LIST T_RPAREN
                    {
                      // printRule("T_LIST T_LPAREN N_CONST_LIST T_RPAREN", "N_LIST_EXPR");
                      $$.type = LIST;
                      $$.numParams = NOT_APPLICABLE;
                      $$.returnType = NOT_APPLICABLE;
                      $$.value = new vector<TYPE_INFO>(*(vector<TYPE_INFO>*)($3.value));
                      metaList.clear();
                    }
                  | T_LBRACKET N_CONST_LIST T_RBRACKET
                    {
                      // printRule(" T_RBRACKET N_CONST_LIST T_LBRACKET", "N_LIST_EXPR");
                      $$.type = LIST;
                      $$.numParams = NOT_APPLICABLE;
                      $$.returnType = NOT_APPLICABLE;
                      $$.value = new vector<TYPE_INFO>(*(vector<TYPE_INFO>*)($2.value));
                      metaList.clear();
                    }
                  ;
N_DICT_EXPR       : T_LBRACE N_DICT_CONST_LIST T_RBRACE
                    {
                      // printRule("T_LBRACE N_DICT_CONST_LIST T_RBRACE", "N_DICT_EXPR");
                    }
                  ;
N_DICT_CONST_LIST : N_CONST T_COLON N_CONST T_COMMA N_DICT_CONST_LIST
                    {
                      // printRule("N_CONST T_COLON N_CONST T_COMMA N_DICT_CONST_LIST", "N_DICT_CONST_LIST");
                    }
                  | N_CONST T_COLON N_CONST
                    {
                      // printRule("N_CONST T_COLON N_CONST", "N_DICT_CONST_LIST");
                    }
                  ;
N_CONST_LIST      : N_CONST T_COMMA N_CONST_LIST
                    {
                      // printRule("CONST_LIST", "CONST, CONST_LIST");
                      TYPE_INFO temp;
                      temp.type = $1.type;
                      if ($1.type == STR)
                      {
                        temp.value = new string(*(string*)($1.value));
                      }
                      else if ($1.type == INT)
                      {
                        temp.value = new int(*(int*)($1.value));
                      }
                      else if ($1.type == FLOAT)
                      {
                        temp.value = new float(*(float*)($1.value));
                      }
                      else if ($1.type == BOOL)
                      {
                        temp.value = new bool(*(bool*)($1.value));
                      }
                      metaList.insert(metaList.begin(), temp);
                      $$.value = new vector<TYPE_INFO>(metaList);
                    }
                  | N_LIST_EXPR T_COMMA N_CONST_LIST
                    {
                      TYPE_INFO temp;
                      temp.type = LIST;
                      temp.value = new vector<TYPE_INFO>(*(vector<TYPE_INFO>*)($1.value));
                      metaList.insert(metaList.begin(), temp);
                      $$.value = new vector<TYPE_INFO>(metaList);
                    }
                  | N_CONST
                    {
                      // printRule("CONST_LIST", "CONST");
                      TYPE_INFO temp;
                      temp.type = $1.type;
                      if ($1.type == STR)
                      {
                        temp.value = new string(*(string*)($1.value));
                      }
                      else if ($1.type == INT)
                      {
                        temp.value = new int(*(int*)($1.value));
                      }
                      else if ($1.type == FLOAT)
                      {
                        temp.value = new float(*(float*)($1.value));
                      }
                      else if ($1.type == BOOL)
                      {
                        temp.value = new bool(*(bool*)($1.value));
                      }
                      metaList.push_back(temp);
                      $$.value = new vector<TYPE_INFO>(metaList);
                    }
                  | N_LIST_EXPR
                    {
                      TYPE_INFO temp;
                      temp.type = LIST;
                      temp.value = new vector<TYPE_INFO>(*(vector<TYPE_INFO>*)($1.value));
                      metaList.push_back(temp);
                      $$.value = new vector<TYPE_INFO>(metaList);
                    }
                  | /* epsilon */
                    {
                      $$.value = new vector<TYPE_INFO>(metaList);
                    }
                  ;
N_FUNCTION_CALL   : T_IDENT T_LPAREN N_ARG_LIST T_RPAREN
                    {
                      // printRule("T_IDENT T_LPAREN N_ARG_LIST T_RPAREN", "N_FUNCTION_CALL");
                      if (!findEntryInAnyScope($1))
                        yyerror("Undefined identifier");
                      else if (findEntryInAnyScopeTYPE($1).type != FUNCTION)
                        yyerror("Arg 1 must be function");
                      else if (findEntryInAnyScopeTYPE($1).numParams < $3.numParams)
                        yyerror("Too many parameters in function call");
                      else if (findEntryInAnyScopeTYPE($1).numParams > $3.numParams)
                        yyerror("Too few parameters in function call");
                      $$.type = findEntryInAnyScopeTYPE($1).returnType;
                    }
                  ;
N_ARG_LIST        : N_ARGS
                    {
                      // printRule("N_ARGS", "N_ARG_LIST");
                      $$.numParams = $1.numParams;
                    }
                  | N_NO_ARGS
                    {
                      // printRule("N_NO_ARGS", "N_ARG_LIST");
                      $$.numParams = 0;
                    }
                  ;
N_NO_ARGS         : /* epsilon */
                    {
                      // printRule("EPSILON", "N_NO_ARGS");
                    }
                  ;
N_ARGS            : N_EXPR
                    {
                      // printRule("N_EXPR", "N_ARGS");
                      if ($1.type != INT && $1.type != BOOL)
                        yyerror("Function parameters must be integer");
                      $$.numParams = 1;
                    }
                  | N_EXPR T_COMMA N_ARGS
                    {
                      // printRule("N_EXPR T_COMMA N_ARGS", "N_ARGS");
                      if ($1.type != INT && $1.type != BOOL)
                        yyerror("Function parameters must be integer");
                      $$.numParams = 1 + $3.numParams;
                    }
                  ;
N_QUIT_EXPR       : T_QUIT T_LPAREN T_RPAREN
                    {
                      // printRule("T_QUIT T_LPAREN T_RPAREN", "N_QUIT_EXPR");
                      exit(0);
                    }
                  ;
N_ARITHLOGIC_EXPR : N_SIMP_ARITHLOGIC
                    {
                      // printRule("ARITHLOGIC_EXPR", "SIMPLE_ARITHLOGIC");
                      $$.type = $1.type;
                      if ($1.type == INT)
                      {
                        $$.value = new int(*(int*)($1.value));
                      }
                      else if ($1.type == FLOAT)
                      {
                        $$.value = new float(*(float*)($1.value));
                      }
                      else if ($1.type == BOOL)
                      {
                        $$.value = new bool(*(bool*)($1.value));
                      }
                      else if ($1.type == STR)
                      {
                        $$.value = new string(*(string*)($1.value));
                      }
                    }
                  | N_SIMP_ARITHLOGIC N_REL_OP N_SIMP_ARITHLOGIC
                    {
                      // printRule("ARITHLOGIC_EXPR", "SIMPLE_ARITHLOGIC REL_OP SIMPLE_ARITHLOGIC");
                      if ($1.type != INT && $1.type != FLOAT && $1.type != BOOL)
                          yyerror("Arg 1 must be integer or float or bool");
                      if ($3.type != INT && $3.type != FLOAT && $3.type != BOOL)
                          yyerror("Arg 2 must be integer or float or bool");
                      $$.type = BOOL;
                      if ($2.type == LT)
                      {
                        if ($1.type == INT)
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool(*(int*)($1.value) < *(int*)($3.value));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool(*(int*)($1.value) < *(float*)($3.value));
                          }
                          else
                          {
                            $$.value = new bool(*(int*)($1.value) < *(bool*)($3.value));
                          }
                        }
                        else if ($1.type == FLOAT)
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool(*(float*)($1.value) < *(int*)($3.value));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool(*(float*)($1.value) < *(float*)($3.value));
                          }
                          else
                          {
                            $$.value = new bool(*(float*)($1.value) < *(bool*)($3.value));
                          }
                        }
                        else
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool(*(bool*)($1.value) < *(int*)($3.value));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool(*(bool*)($1.value) < *(float*)($3.value));
                          }
                          else
                          {
                            $$.value = new bool(*(bool*)($1.value) < *(bool*)($3.value));
                          }
                        }
                      }
                      else if ($2.type == GT)
                      {
                        if ($1.type == INT)
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool(*(int*)($1.value) > *(int*)($3.value));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool(*(int*)($1.value) > *(float*)($3.value));
                          }
                          else
                          {
                            $$.value = new bool(*(int*)($1.value) > *(bool*)($3.value));
                          }
                        }
                        else if ($1.type == FLOAT)
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool(*(float*)($1.value) > *(int*)($3.value));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool(*(float*)($1.value) > *(float*)($3.value));
                          }
                          else
                          {
                            $$.value = new bool(*(float*)($1.value) > *(bool*)($3.value));
                          }
                        }
                        else
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool(*(bool*)($1.value) > *(int*)($3.value));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool(*(bool*)($1.value) > *(float*)($3.value));
                          }
                          else
                          {
                            $$.value = new bool(*(bool*)($1.value) > *(bool*)($3.value));
                          }
                        }
                      }
                      else if ($2.type == EQ)
                      {
                        if ($1.type == INT)
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool(*(int*)($1.value) == *(int*)($3.value));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool(*(int*)($1.value) == *(float*)($3.value));
                          }
                          else
                          {
                            $$.value = new bool(*(int*)($1.value) == *(bool*)($3.value));
                          }
                        }
                        else if ($1.type == FLOAT)
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool(*(float*)($1.value) == *(int*)($3.value));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool(*(float*)($1.value) == *(float*)($3.value));
                          }
                          else
                          {
                            $$.value = new bool(*(float*)($1.value) == *(bool*)($3.value));
                          }
                        }
                        else
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool(*(bool*)($1.value) == *(int*)($3.value));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool(*(bool*)($1.value) == *(float*)($3.value));
                          }
                          else
                          {
                            $$.value = new bool(*(bool*)($1.value) == *(bool*)($3.value));
                          }
                        }
                      }
                      else if ($2.type == LE)
                      {
                        if ($1.type == INT)
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool(*(int*)($1.value) <= *(int*)($3.value));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool(*(int*)($1.value) <= *(float*)($3.value));
                          }
                          else
                          {
                            $$.value = new bool(*(int*)($1.value) <= *(bool*)($3.value));
                          }
                        }
                        else if ($1.type == FLOAT)
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool(*(float*)($1.value) <= *(int*)($3.value));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool(*(float*)($1.value) <= *(float*)($3.value));
                          }
                          else
                          {
                            $$.value = new bool(*(float*)($1.value) <= *(bool*)($3.value));
                          }
                        }
                        else
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool(*(bool*)($1.value) <= *(int*)($3.value));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool(*(bool*)($1.value) <= *(float*)($3.value));
                          }
                          else
                          {
                            $$.value = new bool(*(bool*)($1.value) <= *(bool*)($3.value));
                          }
                        }
                      }
                      else if ($2.type == GE)
                      {
                        if ($1.type == INT)
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool(*(int*)($1.value) >= *(int*)($3.value));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool(*(int*)($1.value) >= *(float*)($3.value));
                          }
                          else
                          {
                            $$.value = new bool(*(int*)($1.value) >= *(bool*)($3.value));
                          }
                        }
                        else if ($1.type == FLOAT)
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool(*(float*)($1.value) >= *(int*)($3.value));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool(*(float*)($1.value) >= *(float*)($3.value));
                          }
                          else
                          {
                            $$.value = new bool(*(float*)($1.value) >= *(bool*)($3.value));
                          }
                        }
                        else
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool(*(bool*)($1.value) >= *(int*)($3.value));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool(*(bool*)($1.value) >= *(float*)($3.value));
                          }
                          else
                          {
                            $$.value = new bool(*(bool*)($1.value) >= *(bool*)($3.value));
                          }
                        }
                      }
                      else if ($2.type == NE)
                      {
                        if ($1.type == INT)
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool(*(int*)($1.value) != *(int*)($3.value));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool(*(int*)($1.value) != *(float*)($3.value));
                          }
                          else
                          {
                            $$.value = new bool(*(int*)($1.value) != *(bool*)($3.value));
                          }
                        }
                        else if ($1.type == FLOAT)
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool(*(float*)($1.value) != *(int*)($3.value));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool(*(float*)($1.value) != *(float*)($3.value));
                          }
                          else
                          {
                            $$.value = new bool(*(float*)($1.value) != *(bool*)($3.value));
                          } 
                        }
                        else
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool(*(bool*)($1.value) != *(int*)($3.value));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool(*(bool*)($1.value) != *(float*)($3.value));
                          }
                          else
                          {
                            $$.value = new bool(*(bool*)($1.value) != *(bool*)($3.value));
                          }
                        }
                      }
                    }
                  ;
N_SIMP_ARITHLOGIC : N_TERM N_ADD_OP_LIST
                    {
                      if ($2.type != UNDEF)
                      {
                        if ($1.type != INT && $1.type != FLOAT && $1.type != BOOL)
                          yyerror("Arg 1 must be integer or float or bool");
                        if ($2.operand == ADD)
                        {
                          if ($1.type == INT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new int((*(int*)($1.value)) + (*(int*)($2.value)));
                              $$.type = INT;
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new float((*(int*)($1.value)) + (*(float*)($2.value)));
                              $$.type = FLOAT;
                            }
                            else
                            {
                              $$.value = new int((*(int*)($1.value)) + (*(bool*)($2.value)));
                              $$.type = INT;
                            }
                          }
                          else if ($1.type == FLOAT)
                          {
                            $$.type = FLOAT;
                            if ($2.type == INT)
                            {
                              $$.value = new float((*(float*)($1.value)) + (*(int*)($2.value)));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new float((*(float*)($1.value)) + (*(float*)($2.value)));
                            }
                            else
                            {
                              $$.value = new float((*(float*)($1.value)) + (*(bool*)($2.value)));
                            }
                          }
                          else
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new int((*(bool*)($1.value)) + (*(int*)($2.value)));
                              $$.type = INT;
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new float((*(bool*)($1.value)) + (*(float*)($2.value)));
                              $$.type = FLOAT;
                            }
                            else
                            {
                              $$.value = new int((*(bool*)($1.value)) + (*(bool*)($2.value)));
                              $$.type = INT;
                            }
                          }
                        }
                        else if ($2.operand == OR)
                        {
                          $$.type = BOOL;
                          if ($1.type == INT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool((*(int*)($1.value)) || (*(int*)($2.value)));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool((*(int*)($1.value)) || (*(float*)($2.value)));
                            }
                            else
                            {
                              $$.value = new bool((*(int*)($1.value)) || (*(bool*)($2.value)));
                            }
                          }
                          else if ($1.type == FLOAT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool((*(float*)($1.value)) || (*(int*)($2.value)));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool((*(float*)($1.value)) || (*(float*)($2.value)));
                            }
                            else
                            {
                              $$.value = new bool((*(float*)($1.value)) || (*(bool*)($2.value)));
                            }
                          }
                          else
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool((*(bool*)($1.value)) || (*(int*)($2.value)));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool((*(bool*)($1.value)) || (*(float*)($2.value)));
                            }
                            else
                            {
                              $$.value = new bool((*(bool*)($1.value)) || (*(bool*)($2.value)));
                            }
                          }
                        }
                        else
                        {
                          if ($1.type == INT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new int((*(int*)($1.value)) - (*(int*)($2.value)));
                              $$.type = INT;
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new float((*(int*)($1.value)) - (*(float*)($2.value)));
                              $$.type = FLOAT;
                            }
                            else
                            {
                              $$.value = new int((*(int*)($1.value)) - (*(bool*)($2.value)));
                              $$.type = INT;
                            }
                          }
                          else if ($1.type == FLOAT)
                          {
                            $$.type = FLOAT;
                            if ($2.type == INT)
                            {
                              $$.value = new float((*(float*)($1.value)) - (*(int*)($2.value)));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new float((*(float*)($1.value)) - (*(float*)($2.value)));
                            }
                            else
                            {
                              $$.value = new float((*(float*)($1.value)) - (*(bool*)($2.value)));
                            }
                          }
                          else
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new int((*(bool*)($1.value)) - (*(int*)($2.value)));
                              $$.type = INT;
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new float((*(bool*)($1.value)) - (*(float*)($2.value)));
                              $$.type = FLOAT;
                            }
                            else
                            {
                              $$.value = new int((*(bool*)($1.value)) - (*(bool*)($2.value)));
                              $$.type = INT;
                            }
                          }
                        }
                      }
                      else
                      {
                        if ($1.type == INT)
                        {
                          $$.value = new int(*(int*)($1.value));
                          $$.type = $1.type;
                        }
                        else if ($1.type == FLOAT)
                        {
                          $$.value = new float(*(float*)($1.value));
                          $$.type = $1.type;
                        }
                        else if ($1.type == BOOL)
                        {
                          $$.value = new bool(*(bool*)($1.value));
                          $$.type = $1.type;
                        }
                        else if ($1.type == STR)
                        {
                          $$.value = new std::string(*(std::string*)($1.value));
                          $$.type = STR;
                        }
                      }
                      // printRule("SIMPLE_ARITHLOGIC", "TERM ADD_OP_LIST");
                    }
                  ;
N_ADD_OP_LIST     : N_ADD_OP N_TERM N_ADD_OP_LIST
                    {
                      // printRule("ADD_OP_LIST", "ADD_OP TERM ADD_OP_LIST");
                      if ($2.type != INT && $2.type != FLOAT && $2.type != BOOL)
                        yyerror("Arg 2 must be integer or float or bool");
                      if ($3.type != UNDEF)
                      {
                        $$.operand = $1.type;
                        if ($3.operand == ADD)
                        {
                          if ($2.type == INT)
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new int((*(int*)($2.value)) + (*(int*)($3.value)));
                              $$.type = INT;
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new float((*(int*)($2.value)) + (*(float*)($3.value)));
                              $$.type = FLOAT;
                            }
                            else
                            {
                              $$.value = new int((*(int*)($2.value)) + (*(bool*)($3.value)));
                              $$.type = INT;
                            }
                          }
                          else if ($2.type == FLOAT)
                          {
                            $$.type = FLOAT;
                            if ($3.type == INT)
                            {
                              $$.value = new float((*(float*)($2.value)) + (*(int*)($3.value)));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new float((*(float*)($2.value)) + (*(float*)($3.value)));
                            }
                            else
                            {
                              $$.value = new float((*(float*)($2.value)) + (*(bool*)($3.value)));
                            }
                          }
                          else
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new int((*(bool*)($2.value)) + (*(int*)($3.value)));
                              $$.type = INT;
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new float((*(bool*)($2.value)) + (*(float*)($3.value)));
                              $$.type = FLOAT;
                            }
                            else
                            {
                              $$.value = new int((*(bool*)($2.value)) + (*(bool*)($3.value)));
                              $$.type = INT;
                            }
                          }
                        }
                        else if ($3.operand == OR)
                        {
                          $$.type = BOOL;
                          if ($2.type == INT)
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool((*(int*)($2.value)) || (*(int*)($3.value)));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool((*(int*)($2.value)) || (*(float*)($3.value)));
                            }
                            else
                            {
                              $$.value = new bool((*(int*)($2.value)) || (*(bool*)($3.value)));
                            }
                          }
                          else if ($2.type == FLOAT)
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool((*(float*)($2.value)) || (*(int*)($3.value)));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool((*(float*)($2.value)) || (*(float*)($3.value)));
                            }
                            else
                            {
                              $$.value = new bool((*(float*)($2.value)) || (*(bool*)($3.value)));
                            }
                          }
                          else
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool((*(bool*)($2.value)) || (*(int*)($3.value)));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool((*(bool*)($2.value)) || (*(float*)($3.value)));
                            }
                            else
                            {
                              $$.value = new bool((*(bool*)($2.value)) || (*(bool*)($3.value)));
                            }
                          }
                        }
                        else
                        {
                          if ($2.type == INT)
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new int((*(int*)($2.value)) - (*(int*)($3.value)));
                              $$.type = INT;
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new float((*(int*)($2.value)) - (*(float*)($3.value)));
                              $$.type = FLOAT;
                            }
                            else
                            {
                              $$.value = new int((*(int*)($2.value)) - (*(bool*)($3.value)));
                              $$.type = INT;
                            }
                          }
                          else if ($2.type == FLOAT)
                          {
                            $$.type = FLOAT;
                            if ($3.type == INT)
                            {
                              $$.value = new float((*(float*)($2.value)) - (*(int*)($3.value)));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new float((*(float*)($2.value)) - (*(float*)($3.value)));
                            }
                            else
                            {
                              $$.value = new float((*(float*)($2.value)) - (*(bool*)($3.value)));
                            }
                          }
                          else
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new int((*(bool*)($2.value)) - (*(int*)($3.value)));
                              $$.type = INT;
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new float((*(bool*)($2.value)) - (*(float*)($3.value)));
                              $$.type = FLOAT;
                            }
                            else
                            {
                              $$.value = new int((*(bool*)($2.value)) - (*(bool*)($3.value)));
                              $$.type = INT;
                            }
                          }
                        }
                      }
                      else
                      {
                        $$.operand = $1.type;
                        if ($2.type == INT)
                        {
                          $$.value = new int(*(int*)($2.value));
                          $$.type = $2.type;
                        }
                        else if ($2.type == FLOAT)
                        {
                          $$.value = new float(*(float*)($2.value));
                          $$.type = $2.type;
                        }
                        else
                        {
                          $$.value = new bool(*(bool*)($2.value));
                          $$.type = $2.type;
                        }
                      }
                    }
                  | /* epsilon */
                    {
                    // printRule("ADD_OP_LIST", "epsilon");
                    $$.type = UNDEF;
                    }
                  ;
N_TERM            : N_FACTOR N_MULT_OP_LIST
                    {
                      // printRule("TERM", "FACTOR MULT_OP_LIST");
                      if ($2.type == UNDEF)
                      {
                        $$.type = $1.type;
                        if ($1.type == INT)
                        {
                          $$.value = new int(*(int*)($1.value));
                        }
                        else if ($1.type == FLOAT)
                        {
                          $$.value = new float(*(float*)($1.value));
                        }
                        else if ($1.type == BOOL)
                        {
                          $$.value = new bool(*(bool*)($1.value));
                        }
                        else if ($1.type == STR)
                        {
                          $$.value = new string(*(string*)($1.value));
                        }
                        else if ($1.type == LIST)
                        {
                          $$.value = new vector<TYPE_INFO>(*(vector<TYPE_INFO>*)($1.value));
                        }
                      }
                      else
                      {
                        if ($1.type != INT && $1.type != FLOAT && $1.type != BOOL)
                          yyerror("Arg 1 must be integer or float or bool");
                        if ($2.operand == MULT)
                        {
                          if ($1.type == INT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new int((*(int*)($1.value)) * (*(int*)($2.value)));
                              $$.type = INT;
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new float((*(int*)($1.value)) * (*(float*)($2.value)));
                              $$.type = FLOAT;
                            }
                            else
                            {
                              $$.value = new int((*(int*)($1.value)) * (*(bool*)($2.value)));
                              $$.type = INT;
                            }
                          }
                          else if ($1.type == FLOAT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new float((*(float*)($1.value)) * (*(int*)($2.value)));
                              $$.type = FLOAT;
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new float((*(float*)($1.value)) * (*(float*)($2.value)));
                              $$.type = FLOAT;
                            }
                            else
                            {
                              $$.value = new float((*(float*)($1.value)) * (*(bool*)($2.value)));
                              $$.type = FLOAT;
                            }
                          }
                          else
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new int((*(bool*)($1.value)) * (*(int*)($2.value)));
                              $$.type = INT;
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new float((*(bool*)($1.value)) * (*(float*)($2.value)));
                              $$.type = FLOAT;
                            }
                            else
                            {
                              $$.value = new bool((*(bool*)($1.value)) * (*(bool*)($2.value)));
                              $$.type = BOOL;
                            }
                          }
                        }
                        else if ($2.operand == DIV)
                        {
                          if ($1.type == INT)
                          {
                            if ($2.type == INT)
                            {
                              if ((*(int*)($2.value)) == 0)
                                yyerror("Attempted division by zero");
                              $$.value = new int((*(int*)($1.value)) / (*(int*)($2.value)));
                              $$.type = INT;
                            }
                            else if ($2.type == FLOAT)
                            {
                              if ((*(float*)($2.value)) == 0)
                                yyerror("Attempted division by zero");
                              $$.value = new float((*(int*)($1.value)) / (*(float*)($2.value)));
                              $$.type = FLOAT;
                            }
                            else
                            {
                              if ((*(bool*)($2.value)) == 0)
                                yyerror("Attempted division by zero");
                              $$.value = new int((*(int*)($1.value)) / (*(bool*)($2.value)));
                              $$.type = INT;
                            }
                          }
                          else if ($1.type == FLOAT)
                          {
                            if ($2.type == INT)
                            {
                              if ((*(int*)($2.value)) == 0)
                                yyerror("Attempted division by zero");
                              $$.value = new float((*(float*)($1.value)) / (*(int*)($2.value)));
                              $$.type = FLOAT;
                            }
                            else if ($2.type == FLOAT)
                            {
                              if ((*(float*)($2.value)) == 0)
                                yyerror("Attempted division by zero");
                              $$.value = new float((*(float*)($1.value)) / (*(float*)($2.value)));
                              $$.type = FLOAT;
                            }
                            else
                            {
                              if ((*(bool*)($2.value)) == 0)
                                yyerror("Attempted division by zero");
                              $$.value = new float((*(float*)($1.value)) / (*(bool*)($2.value)));
                              $$.type = FLOAT;
                            }
                          }
                          else
                          {
                            if ($2.type == INT)
                            {
                              if ((*(int*)($2.value)) == 0)
                                yyerror("Attempted division by zero");
                              $$.value = new int((*(bool*)($1.value)) / (*(int*)($2.value)));
                              $$.type = INT;
                            }
                            else if ($2.type == FLOAT)
                            {
                              if ((*(float*)($2.value)) == 0)
                                yyerror("Attempted division by zero");
                              $$.value = new float((*(bool*)($1.value)) / (*(float*)($2.value)));
                              $$.type = FLOAT;
                            }
                            else
                            {
                              if ((*(bool*)($2.value)) == 0)
                                yyerror("Attempted division by zero");
                              $$.value = new bool((*(bool*)($1.value)) / (*(bool*)($2.value)));
                              $$.type = BOOL;
                            }
                          }
                        }
                        else if ($2.operand == AND)
                        {
                          $$.type = BOOL;
                          if ($1.type == INT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool((*(int*)($1.value)) && (*(int*)($2.value)));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool((*(int*)($1.value)) && (*(float*)($2.value)));
                            }
                            else
                            {
                              $$.value = new bool((*(int*)($1.value)) && (*(bool*)($2.value)));
                            }
                          }
                          else if ($1.type == FLOAT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool((*(float*)($1.value)) && (*(int*)($2.value)));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool((*(float*)($1.value)) && (*(float*)($2.value)));
                            }
                            else
                            {
                              $$.value = new bool((*(float*)($1.value)) && (*(bool*)($2.value)));
                            }
                          }
                          else
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool((*(bool*)($1.value)) && (*(int*)($2.value)));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool((*(bool*)($1.value)) && (*(float*)($2.value)));
                            }
                            else
                            {
                              $$.value = new bool((*(bool*)($1.value)) && (*(bool*)($2.value)));
                            }
                          }
                        }
                        else if ($2.operand == MOD)
                        {
                          if ($1.type == INT)
                          {
                            if ($2.type == INT)
                            {
                              if ((*(int*)($2.value)) == 0)
                                yyerror("Attempted division by zero");
                              $$.value = new int((*(int*)($1.value)) % (*(int*)($2.value)));
                              $$.type = INT;
                            }
                            else if ($2.type == FLOAT)
                            {
                              if ((*(float*)($2.value)) == 0)
                                yyerror("Attempted division by zero");
                              $$.value = new float(fmod((*(int*)($1.value)), (*(float*)($2.value))));
                              $$.type = FLOAT;
                            }
                            else
                            {
                              if ((*(bool*)($2.value)) == 0)
                                yyerror("Attempted division by zero");
                              $$.value = new int((*(int*)($1.value)) % (*(bool*)($2.value)));
                              $$.type = INT;
                            }
                          }
                          else if ($1.type == FLOAT)
                          {
                            if ($2.type == INT)
                            {
                              if ((*(int*)($2.value)) == 0)
                                yyerror("Attempted division by zero");
                              $$.value = new float(fmod((*(float*)($1.value)), (*(int*)($2.value))));
                              $$.type = FLOAT;
                            }
                            else if ($2.type == FLOAT)
                            {
                              if ((*(float*)($2.value)) == 0)
                                yyerror("Attempted division by zero");
                              $$.value = new float(fmod((*(float*)($1.value)), (*(float*)($2.value))));
                              $$.type = FLOAT;
                            }
                            else
                            {
                              if ((*(bool*)($2.value)) == 0)
                                yyerror("Attempted division by zero");
                              $$.value = new float(fmod((*(float*)($1.value)), (*(bool*)($2.value))));
                              $$.type = FLOAT;
                            }
                          }
                          else
                          {
                            if ($2.type == INT)
                            {
                              if ((*(int*)($2.value)) == 0)
                                yyerror("Attempted division by zero");
                              $$.value = new bool((*(bool*)($1.value)) % (*(int*)($2.value)));
                              $$.type = BOOL;
                            }
                            else if ($2.type == FLOAT)
                            {
                              if ((*(float*)($2.value)) == 0)
                                yyerror("Attempted division by zero");
                              $$.value = new bool(fmod((*(bool*)($1.value)), (*(float*)($2.value))));
                              $$.type = BOOL;
                            }
                            else
                            {
                              if ((*(bool*)($2.value)) == 0)
                                yyerror("Attempted division by zero");
                              $$.value = new bool((*(bool*)($1.value)) % (*(bool*)($2.value)));
                              $$.type = BOOL;
                            }
                          }
                        }
                        else
                        {
                          if ($1.type == INT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new int(pow((*(int*)($1.value)), (*(int*)($2.value))));
                              $$.type = INT;
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new float(pow((*(int*)($1.value)), (*(float*)($2.value))));
                              $$.type = FLOAT;
                            }
                            else
                            {
                              $$.value = new int(pow((*(int*)($1.value)), (*(bool*)($2.value))));
                              $$.type = INT;
                            }
                          }
                          else if ($1.type == FLOAT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new float(pow((*(float*)($1.value)), (*(int*)($2.value))));
                              $$.type = FLOAT;
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new float(pow((*(float*)($1.value)), (*(float*)($2.value))));
                              $$.type = FLOAT;
                            }
                            else
                            {
                              $$.value = new float(pow((*(float*)($1.value)), (*(bool*)($2.value))));
                              $$.type = FLOAT;
                            }
                          }
                          else
                          {
                            $$.type = BOOL;
                            if ($2.type == INT)
                            {
                              $$.value = new int(pow((*(bool*)($1.value)), (*(int*)($2.value))));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new float(pow((*(bool*)($1.value)), (*(float*)($2.value))));
                            }
                            else
                            {
                              $$.value = new bool(pow((*(bool*)($1.value)), (*(bool*)($2.value))));
                            }
                          }
                        }
                      }
                    }
                  ;
N_MULT_OP_LIST    : N_MULT_OP N_FACTOR N_MULT_OP_LIST
                    {
                    // printRule("MULT_OP_LIST", "MULT_OP FACTOR MULT_OP_LIST");
                    if ($2.type != INT && $2.type != FLOAT && $2.type != BOOL)
                      yyerror("Arg 2 must be integer or float or bool");
                    if ($3.type != UNDEF)
                    {
                      $$.operand = $1.type;
                      if ($3.operand == MULT)
                      {
                        if ($2.type == INT)
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new int((*(int*)($2.value)) * (*(int*)($3.value)));
                            $$.type = INT;
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new float((*(int*)($2.value)) * (*(float*)($3.value)));
                            $$.type = FLOAT;
                          }
                          else
                          {
                            $$.value = new int((*(int*)($2.value)) * (*(bool*)($3.value)));
                            $$.type = INT;
                          }
                        }
                        else if ($2.type == FLOAT)
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new float((*(float*)($2.value)) * (*(int*)($3.value)));
                            $$.type = FLOAT;
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new float((*(float*)($2.value)) * (*(float*)($3.value)));
                            $$.type = FLOAT;
                          }
                          else
                          {
                            $$.value = new float((*(float*)($2.value)) * (*(bool*)($3.value)));
                            $$.type = FLOAT;
                          }
                        }
                        else
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new int((*(bool*)($2.value)) * (*(int*)($3.value)));
                            $$.type = INT;
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new float((*(bool*)($2.value)) * (*(float*)($3.value)));
                            $$.type = FLOAT;
                          }
                          else
                          {
                            $$.value = new bool((*(bool*)($2.value)) * (*(bool*)($3.value)));
                            $$.type = BOOL;
                          }
                        }
                      }
                      else if ($3.operand == DIV)
                      {
                        if ($2.type == INT)
                        {
                          if ($3.type == INT)
                          {
                            if ((*(int*)($3.value)) == 0)
                              yyerror("Attempted division by zero");
                            $$.value = new int((*(int*)($2.value)) / (*(int*)($3.value)));
                            $$.type = INT;
                          }
                          else if ($3.type == FLOAT)
                          {
                            if ((*(float*)($3.value)) == 0)
                              yyerror("Attempted division by zero");
                            $$.value = new float((*(int*)($2.value)) / (*(float*)($3.value)));
                            $$.type = FLOAT;
                          }
                          else
                          {
                            if ((*(bool*)($3.value)) == 0)
                              yyerror("Attempted division by zero");
                            $$.value = new int((*(int*)($2.value)) / (*(bool*)($3.value)));
                            $$.type = INT;
                          }
                        }
                        else if ($2.type == FLOAT)
                        {
                          if ($3.type == INT)
                          {
                            if ((*(int*)($3.value)) == 0)
                              yyerror("Attempted division by zero");
                            $$.value = new float((*(float*)($2.value)) / (*(int*)($3.value)));
                            $$.type = FLOAT;
                          }
                          else if ($3.type == FLOAT)
                          {
                            if ((*(float*)($3.value)) == 0)
                              yyerror("Attempted division by zero");
                            $$.value = new float((*(float*)($2.value)) / (*(float*)($3.value)));
                            $$.type = FLOAT;
                          }
                          else
                          {
                            if ((*(bool*)($3.value)) == 0)
                              yyerror("Attempted division by zero");
                            $$.value = new float((*(float*)($2.value)) / (*(bool*)($3.value)));
                            $$.type = FLOAT;
                          }
                        }
                        else
                        {
                          if ($3.type == INT)
                          {
                            if ((*(int*)($3.value)) == 0)
                              yyerror("Attempted division by zero");
                            $$.value = new int((*(bool*)($2.value)) / (*(int*)($3.value)));
                            $$.type = INT;
                          }
                          else if ($3.type == FLOAT)
                          {
                            if ((*(float*)($3.value)) == 0)
                              yyerror("Attempted division by zero");
                            $$.value = new float((*(bool*)($2.value)) / (*(float*)($3.value)));
                            $$.type = FLOAT;
                          }
                          else
                          {
                            if ((*(bool*)($3.value)) == 0)
                              yyerror("Attempted division by zero");
                            $$.value = new bool((*(bool*)($2.value)) / (*(bool*)($3.value)));
                            $$.type = BOOL;
                          }
                        }
                      }
                      else if ($3.operand == AND)
                      {
                        $$.type = BOOL;
                        if ($2.type == INT)
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool((*(int*)($2.value)) && (*(int*)($3.value)));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool((*(int*)($2.value)) && (*(float*)($3.value)));
                          }
                          else
                          {
                            $$.value = new bool((*(int*)($2.value)) && (*(bool*)($3.value)));
                          }
                        }
                        else if ($2.type == FLOAT)
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool((*(float*)($2.value)) && (*(int*)($3.value)));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool((*(float*)($2.value)) && (*(float*)($3.value)));
                          }
                          else
                          {
                            $$.value = new bool((*(float*)($2.value)) && (*(bool*)($3.value)));
                          }
                        }
                        else
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new bool((*(bool*)($2.value)) && (*(int*)($3.value)));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new bool((*(bool*)($2.value)) && (*(float*)($3.value)));
                          }
                          else
                          {
                            $$.value = new bool((*(bool*)($2.value)) && (*(bool*)($3.value)));
                          }
                        }
                      }
                      else if ($3.operand == MOD)
                      {
                        if ($2.type == INT)
                        {
                          if ($3.type == INT)
                          {
                            if ((*(int*)($3.value)) == 0)
                              yyerror("Attempted division by zero");
                            $$.value = new int((*(int*)($2.value)) % (*(int*)($3.value)));
                            $$.type = INT;
                          }
                          else if ($3.type == FLOAT)
                          {
                            if ((*(float*)($3.value)) == 0)
                              yyerror("Attempted division by zero");
                            $$.value = new float(fmod((*(int*)($2.value)), (*(float*)($3.value))));
                            $$.type = FLOAT;
                          }
                          else
                          {
                            if ((*(bool*)($3.value)) == 0)
                              yyerror("Attempted division by zero");
                            $$.value = new int((*(int*)($2.value)) % (*(bool*)($3.value)));
                            $$.type = INT;
                          }
                        }
                        else if ($2.type == FLOAT)
                        {
                          if ($3.type == INT)
                          {
                            if ((*(int*)($3.value)) == 0)
                              yyerror("Attempted division by zero");
                            $$.value = new float(fmod((*(float*)($2.value)), (*(int*)($3.value))));
                            $$.type = FLOAT;
                          }
                          else if ($3.type == FLOAT)
                          {
                            if ((*(float*)($3.value)) == 0)
                              yyerror("Attempted division by zero");
                            $$.value = new float(fmod((*(float*)($2.value)), (*(float*)($3.value))));
                            $$.type = FLOAT;
                          }
                          else
                          {
                            if ((*(bool*)($3.value)) == 0)
                              yyerror("Attempted division by zero");
                            $$.value = new float(fmod((*(float*)($2.value)), (*(bool*)($3.value))));
                            $$.type = FLOAT;
                          }
                        }
                        else
                        {
                          if ($3.type == INT)
                          {
                            if ((*(int*)($3.value)) == 0)
                              yyerror("Attempted division by zero");
                            $$.value = new bool((*(bool*)($2.value)) % (*(int*)($3.value)));
                            $$.type = BOOL;
                          }
                          else if ($3.type == FLOAT)
                          {
                            if ((*(float*)($3.value)) == 0)
                              yyerror("Attempted division by zero");
                            $$.value = new bool(fmod((*(bool*)($2.value)), (*(float*)($3.value))));
                            $$.type = BOOL;
                          }
                          else
                          {
                            if ((*(bool*)($3.value)) == 0)
                              yyerror("Attempted division by zero");
                            $$.value = new bool((*(bool*)($2.value)) % (*(bool*)($3.value)));
                            $$.type = BOOL;
                          }
                        }
                      }
                      else
                      {
                        if ($2.type == INT)
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new int(pow((*(int*)($2.value)), (*(int*)($3.value))));
                            $$.type = INT;
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new float(pow((*(int*)($2.value)), (*(float*)($3.value))));
                            $$.type = FLOAT;
                          }
                          else
                          {
                            $$.value = new int(pow((*(int*)($2.value)), (*(bool*)($3.value))));
                            $$.type = INT;
                          }
                        }
                        else if ($2.type == FLOAT)
                        {
                          if ($3.type == INT)
                          {
                            $$.value = new float(pow((*(float*)($2.value)), (*(int*)($3.value))));
                            $$.type = FLOAT;
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new float(pow((*(float*)($2.value)), (*(float*)($3.value))));
                            $$.type = FLOAT;
                          }
                          else
                          {
                            $$.value = new float(pow((*(float*)($2.value)), (*(bool*)($3.value))));
                            $$.type = FLOAT;
                          }
                        }
                        else
                        {
                          $$.type = BOOL;
                          if ($3.type == INT)
                          {
                            $$.value = new int(pow((*(bool*)($2.value)), (*(int*)($3.value))));
                          }
                          else if ($3.type == FLOAT)
                          {
                            $$.value = new float(pow((*(bool*)($2.value)), (*(float*)($3.value))));
                          }
                          else
                          {
                            $$.value = new bool(pow((*(bool*)($2.value)), (*(bool*)($3.value))));
                          }
                        }
                      }
                    }
                    else
                    {
                      if ($2.type == INT)
                      {
                        $$.value = new int(*(int*)($2.value));
                        $$.operand = $1.type;
                        $$.type = $2.type;
                      }
                      else if ($2.type == FLOAT)
                      {
                        $$.value = new float(*(float*)($2.value));
                        $$.operand = $1.type;
                        $$.type = $2.type;
                      }
                      else
                      {
                        $$.value = new bool(*(bool*)($2.value));
                        $$.operand = $1.type;
                        $$.type = $2.type;
                      }
                    }
                  }
                  | /* epsilon */
                    {
                      // printRule("EPSILON", "N_MULT_OP_LIST");
                      $$.type = UNDEF;
                    }
                  ;
N_FACTOR          : N_VAR
                    {
                      // printRule("FACTOR", "VAR");
                      $$.type = $1.type;
                      if ($1.type == INT)
                      {
                        $$.value = new int(*(int*)($1.value));
                      }
                      else if ($1.type == FLOAT)
                      {
                        $$.value = new float(*(float*)($1.value));
                      }
                      else if ($1.type == BOOL)
                      {
                        $$.value = new bool(*(bool*)($1.value));
                      }
                    }
                  | N_CONST
                    {
                      // printRule("FACTOR", "CONST");
                      $$.type = $1.type;
                      if ($1.type == INT)
                      {
                        $$.value = new int(*(int*)($1.value));
                      }
                      else if ($1.type == FLOAT)
                      {
                        $$.value = new float(*(float*)($1.value));
                      }
                      else if ($1.type == BOOL)
                      {
                        $$.value = new bool(*(bool*)($1.value));
                      }
                    }
                  | T_LPAREN N_PAREN_EXPR T_RPAREN
                    {
                      // printRule("FACTOR", "( EXPR )");
                      $$.type = $2.type;
                      if ($2.type == INT)
                      {
                        $$.value = new int(*(int*)($2.value));
                      }
                      else if ($2.type == FLOAT)
                      {
                        $$.value = new float(*(float*)($2.value));
                      }
                      else if ($2.type == BOOL)
                      {
                        $$.value = new bool(*(bool*)($2.value));
                      }
                      else if ($2.type == STR)
                      {
                        $$.value = new string(*(string*)($2.value));
                      }
                      else if ($2.type == LIST)
                      {
                        $$.value = new vector<TYPE_INFO>(*(vector<TYPE_INFO>*)($2.value));
                      }
                    }
                  | T_NOT N_FACTOR
                    {
                      // printRule("FACTOR", "! FACTOR");
                      $$.type = BOOL;
                      if ($2.type == INT)
                      {
                        $$.value = new bool(!(*(int*)($2.value)));
                      }
                      else if ($2.type == FLOAT)
                      {
                        $$.value = new bool(!(*(float*)($2.value)));
                      }
                      else
                      {
                        $$.value = new bool(!(*(bool*)($2.value)));
                      }
                    }
                  ;
N_PAREN_EXPR      : N_IF_EXPR
                    {
                      $$.type = $1.type;
                      if ($1.type == INT)
                      {
                        $$.value = new int(*(int*)($1.value));
                      }
                      else if ($1.type == FLOAT)
                      {
                        $$.value = new float(*(float*)($1.value));
                      }
                      else if ($1.type == BOOL)
                      {
                        $$.value = new bool(*(bool*)($1.value));
                      }
                      else if ($1.type == STR)
                      {
                        $$.value = new string(*(string*)($1.value));
                      }
                    }
                  | N_WHILE_EXPR
                    {
                      $$.type = $1.type;
                      if ($1.type == INT)
                      {
                        $$.value = new int(*(int*)($1.value));
                      }
                      else if ($1.type == FLOAT)
                      {
                        $$.value = new float(*(float*)($1.value));
                      }
                      else if ($1.type == BOOL)
                      {
                        $$.value = new bool(*(bool*)($1.value));
                      }
                      else if ($1.type == STR)
                      {
                        $$.value = new string(*(string*)($1.value));
                      }
                    }
                  | N_FOR_EXPR
                    {
                      $$.type = $1.type;
                      if ($1.type == INT)
                      {
                        $$.value = new int(*(int*)($1.value));
                      }
                      else if ($1.type == FLOAT)
                      {
                        $$.value = new float(*(float*)($1.value));
                      }
                      else if ($1.type == BOOL)
                      {
                        $$.value = new bool(*(bool*)($1.value));
                      }
                      else if ($1.type == STR)
                      {
                        $$.value = new string(*(string*)($1.value));
                      }
                    }
                  | N_ARITHLOGIC_EXPR
                    {
                      $$.type = $1.type;
                      if ($1.type == INT)
                      {
                        $$.value = new int(*(int*)($1.value));
                      }
                      else if ($1.type == FLOAT)
                      {
                        $$.value = new float(*(float*)($1.value));
                      }
                      else if ($1.type == BOOL)
                      {
                        $$.value = new bool(*(bool*)($1.value));
                      }
                      else if ($1.type == STR)
                      {
                        $$.value = new string(*(string*)($1.value));
                      }
                    }
                  | N_ASSIGNMENT_EXPR
                    {
                      $$.type = $1.type;
                      if ($1.type == INT)
                      {
                        $$.value = new int(*(int*)($1.value));
                      }
                      else if ($1.type == FLOAT)
                      {
                        $$.value = new float(*(float*)($1.value));
                      }
                      else if ($1.type == BOOL)
                      {
                        $$.value = new bool(*(bool*)($1.value));
                      }
                      else if ($1.type == STR)
                      {
                        $$.value = new string(*(string*)($1.value));
                      }
                    }
                  | N_OUTPUT_EXPR 
                    {
                      $$.type = $1.type;
                      if ($1.type == INT)
                      {
                        $$.value = new int(*(int*)($1.value));
                      }
                      else if ($1.type == FLOAT)
                      {
                        $$.value = new float(*(float*)($1.value));
                      }
                      else if ($1.type == BOOL)
                      {
                        $$.value = new bool(*(bool*)($1.value));
                      }
                      else if ($1.type == STR)
                      {
                        $$.value = new string(*(string*)($1.value));
                      }
                    }
                  | N_INPUT_EXPR
                    {
                      $$.type = $1.type;
                      if ($1.type == INT)
                      {
                        $$.value = new int(*(int*)($1.value));
                      }
                      else if ($1.type == FLOAT)
                      {
                        $$.value = new float(*(float*)($1.value));
                      }
                      else if ($1.type == BOOL)
                      {
                        $$.value = new bool(*(bool*)($1.value));
                      }
                      else if ($1.type == STR)
                      {
                        $$.value = new string(*(string*)($1.value));
                      }
                    }
                  | N_LIST_EXPR
                    {
                      $$.type = $1.type;
                      $$.value = new vector<TYPE_INFO>(*(vector<TYPE_INFO>*)($1.value));
                    }
                  | N_DICT_EXPR
                    {
                      $$.type = $1.type;
                      if ($1.type == INT)
                      {
                        $$.value = new int(*(int*)($1.value));
                      }
                      else if ($1.type == FLOAT)
                      {
                        $$.value = new float(*(float*)($1.value));
                      }
                      else if ($1.type == BOOL)
                      {
                        $$.value = new bool(*(bool*)($1.value));
                      }
                      else if ($1.type == STR)
                      {
                        $$.value = new string(*(string*)($1.value));
                      }
                    }
                  | N_FUNCTION_DEF
                    {
                      $$.type = $1.type;
                      if ($1.type == INT)
                      {
                        $$.value = new int(*(int*)($1.value));
                      }
                      else if ($1.type == FLOAT)
                      {
                        $$.value = new float(*(float*)($1.value));
                      }
                      else if ($1.type == BOOL)
                      {
                        $$.value = new bool(*(bool*)($1.value));
                      }
                      else if ($1.type == STR)
                      {
                        $$.value = new string(*(string*)($1.value));
                      }
                    }
                  | N_FUNCTION_CALL
                    {
                      $$.type = $1.type;
                      if ($1.type == INT)
                      {
                        $$.value = new int(*(int*)($1.value));
                      }
                      else if ($1.type == FLOAT)
                      {
                        $$.value = new float(*(float*)($1.value));
                      }
                      else if ($1.type == BOOL)
                      {
                        $$.value = new bool(*(bool*)($1.value));
                      }
                      else if ($1.type == STR)
                      {
                        $$.value = new string(*(string*)($1.value));
                      }
                    }
                  | N_QUIT_EXPR
                    {
                      $$.type = $1.type;
                      if ($1.type == INT)
                      {
                        $$.value = new int(*(int*)($1.value));
                      }
                      else if ($1.type == FLOAT)
                      {
                        $$.value = new float(*(float*)($1.value));
                      }
                      else if ($1.type == BOOL)
                      {
                        $$.value = new bool(*(bool*)($1.value));
                      }
                      else if ($1.type == STR)
                      {
                        $$.value = new string(*(string*)($1.value));
                      }
                    }
N_ADD_OP          : T_ADD
                    {
                    // printRule("ADD_OP", "+");
                    $$.type = ADD;
                    }
                  | T_SUB
                    {
                    // printRule("ADD_OP", "-");
                    $$.type = SUB;
                    }
                  | T_OR
                    {
                    // printRule("ADD_OP", "|");
                    $$.type = OR;
                    }
                  ;
N_MULT_OP         : T_MULT
                    {
                    // printRule("MULT_OP", "*");
                    $$.type = MULT;
                    }
                  | T_DIV
                    {
                    // printRule("MULT_OP", "/");
                    $$.type = DIV;
                    }
                  | T_AND
                    {
                    // printRule("MULT_OP", "&");
                    $$.type = AND;
                    }
                  | T_MOD
                    {
                    // printRule("MULT_OP", "%%");
                    $$.type = MOD;
                    }
                  | T_POW
                    {
                    // printRule("MULT_OP", "^");
                    $$.type = POW;
                    }
                  ;
N_REL_OP          : T_LT
                    {
                    // printRule("REL_OP", "<");
                    $$.type = LT;
                    }
                  | T_GT
                    {
                    // printRule("REL_OP", ">");
                    $$.type = GT;
                    }
                  | T_LE
                    {
                    // printRule("REL_OP", "<=");
                    $$.type = LE;
                    }
                  | T_GE
                    {
                    // printRule("REL_OP", ">=");
                    $$.type = GE;
                    }
                  | T_EQ
                    {
                    // printRule("REL_OP", "==");
                    $$.type = EQ;
                    }
                  | T_NE
                    {
                    // printRule("REL_OP", "!=");
                    $$.type = NE;
                    }
                  ;
N_ASSIGN_OP       : T_ASSIGN
                    {
                      // printRule("T_ASSIGN", "T_ASSIGN_OP");
                    }
                  | T_MODEQ
                    {
                      // printRule("T_MODEQ", "T_ASSIGN_OP");
                    }
                  | T_DIVEQ
                    {
                      // printRule("T_DIVEQ", "T_ASSIGN_OP");
                    }
                  | T_SUBEQ
                    {
                      // printRule("T_SUBEQ", "T_ASSIGN_OP");
                    }
                  | T_ADDEQ
                    {
                    // printRule("T_ADDEQ", "T_ASSIGN_OP");
                    }
                  | T_MULTEQ
                    {
                      // printRule("T_MULTEQ", "T_ASSIGN_OP");
                    }
                  | T_POWEQ
                    {
                      // printRule("T_POWEQ", "T_ASSIGN_OP");
                    }
                  ;
N_VAR             : N_ENTIRE_VAR
                    {
                      // printRule("N_ENTIRE_VAR", "N_VAR");
                      $$.type = $1.type;
                    }
                  | N_SINGLE_ELEMENT
                    {
                      // printRule("N_SINGLE_ELEMENT", "N_VAR");
                      $$.type = $1.type;
                    }
                  ;
N_SINGLE_ELEMENT  : T_IDENT T_LBRACKET N_IND_EXPR T_RBRACKET
                    {
                      //  printRule("SINGLE_ELEMENT", "IDENT [[ EXPR ]]");
                      int size = (*(vector<TYPE_INFO>*)(findEntryInAnyScopeTYPE($1).value)).size();
                      if (!findEntryInAnyScope($1))
                        yyerror("Undefined identifier");
                      else if (findEntryInAnyScopeTYPE($1).type != LIST)
                        yyerror("Arg 1 must be list");
                      else if ((*(int*)($3.value)) < -size ||
                               (*(int*)($3.value)) >= size)
                        yyerror("Subscript out of bounds");
                      $$.numParams = NOT_APPLICABLE;
                      $$.returnType = NOT_APPLICABLE;
                      if ((*(int*)($3.value)) < 0)
                      {
                        $$.value = (*(vector<TYPE_INFO>*)(findEntryInAnyScopeTYPE($1).value))[(*(int*)($3.value)) + size].value;
                        $$.type = (*(vector<TYPE_INFO>*)(findEntryInAnyScopeTYPE($1).value))[(*(int*)($3.value)) + size].type;
                      }
                      else
                      {
                        $$.value = (*(vector<TYPE_INFO>*)(findEntryInAnyScopeTYPE($1).value))[(*(int*)($3.value))].value;
                        $$.type = (*(vector<TYPE_INFO>*)(findEntryInAnyScopeTYPE($1).value))[(*(int*)($3.value))].type;
                      }
                    }
                  ;
N_ENTIRE_VAR      : T_IDENT
                    {
                      // printRule("ENTIRE_VAR", "IDENT");
                      if (!findEntryInAnyScope($1))
                        yyerror("Undefined identifier");
                      
                      $$.type = findEntryInAnyScopeTYPE($1).type;
                      $$.numParams = findEntryInAnyScopeTYPE($1).numParams;
                      $$.returnType = findEntryInAnyScopeTYPE($1).returnType;
                      if (ScopeStack.top().findEntry($1).type == STR)
                      {
                        $$.value = new std::string(*(std::string*)(ScopeStack.top().findEntry($1).value));
                      }
                      else if (ScopeStack.top().findEntry($1).type == INT)
                      {
                        $$.value = new int(*(int*)(ScopeStack.top().findEntry($1).value));
                      }
                      else if (ScopeStack.top().findEntry($1).type == FLOAT)
                      {
                        $$.value = new float(*(float*)(ScopeStack.top().findEntry($1).value));
                      }
                      else if (ScopeStack.top().findEntry($1).type == BOOL)
                      {
                        $$.value = new bool(*(bool*)(ScopeStack.top().findEntry($1).value));
                      }
                      else if (ScopeStack.top().findEntry($1).type == LIST)
                      {
                        $$.value = new vector<TYPE_INFO>(*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry($1).value));
                      }
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
  // printf("\n___Entering new scope...\n\n");
}

void endScope()
{
  ScopeStack.pop();
  // printf("\n___Exiting scope...\n\n");
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

void valueAssignment(void* leftValue, void* rightValue, int typeCode)
{
  if (typeCode == STR)
  {
    (leftValue) = new std::string(*(std::string*)(rightValue));
  }
  else if (typeCode == INT)
  {
    (leftValue) = new int(*(int*)(rightValue));
  }
  else if (typeCode == FLOAT)
  {
    (leftValue) = new float(*(float*)(rightValue));
  }
  else if (typeCode == BOOL)
  {
    (leftValue) = new bool(*(bool*)(rightValue));
  }
  else if (typeCode == LIST)
  {
    (leftValue) = new vector<TYPE_INFO>(*(vector<TYPE_INFO>*)(rightValue));
  }
}

void printList(vector<TYPE_INFO> vec)
{
  cout << "[";
  if (vec.size() > 0)
  {
    for (int i = 0; i < vec.size() - 1; i++)
    {
      if (vec[i].type == STR)
      {
        cout << *(string*)(vec[i].value) << ", ";
      }
      else if (vec[i].type == INT)
      {
        cout << *(int*)(vec[i].value) << ", ";
      }
      else if (vec[i].type == FLOAT)
      {
        cout << *(float*)(vec[i].value) << ", ";
      }
      else if (vec[i].type == BOOL)
      {
        cout << (*(bool*)(vec[i].value) ? ("True") : ("False")) << ", ";
      }
      else if (vec[i].type == LIST)
      {
        printList(*(vector<TYPE_INFO>*)(vec[i].value));
        cout << ", ";
      }
    }
    if (vec[vec.size() - 1].type == STR)
    {
      cout << *(string*)(vec[vec.size() - 1].value);
    }
    else if (vec[vec.size() - 1].type == INT)
    {
      cout << *(int*)(vec[vec.size() - 1].value);
    }
    else if (vec[vec.size() - 1].type == FLOAT)
    {
      cout << *(float*)(vec[vec.size() - 1].value);
    }
    else if (vec[vec.size() - 1].type == BOOL)
    {
      cout << (*(bool*)(vec[vec.size() - 1].value) ? ("True") : ("False"));
    }
    else if (vec[vec.size() - 1].type == LIST)
      {
        printList(*(vector<TYPE_INFO>*)(vec[vec.size() - 1].value));
      }
  }
  cout << "]";
}

void outputValue(void const * const value, const int type)
{
  if (type == INT)
  {
    cout << *(int*)(value) << endl;
  }
  else if (type == FLOAT)
  {
    cout << *(float*)(value) << endl;
  }
  else if (type == STR)
  {
    cout << *(std::string*)(value) << endl;
  }
  else if (type == BOOL)
  {
    cout << *(bool*)(value) << endl;
  }
  else if (type == LIST)
  {
    printList(*(vector<TYPE_INFO>*)(value));
    cout << endl;
  }
}

int main()
{
  beginScope();
  cout << ">>> ";
  cout.setf(ios::fixed); 
  cout.setf(ios::showpoint); 
  cout.precision(16);
  do
  {
	  yyparse();
  } while (!feof(yyin));

  return(0);
}