%{
#include <stdio.h>
#include <stack>
#include <iostream>
#include <vector>
#include <iomanip>
#include <math.h>
#include <typeinfo>
#include "SymbolTable.h"
#define min(a, b) (a < b ? a : b)
#define max(a, b) (a > b ? a : b)

stack<SYMBOL_TABLE> ScopeStack;
stack<SYMBOL_TABLE> ifScopeRestore, elseScopeRestore;

int numLines = 1;
string assignmentName;
vector<TYPE_INFO> metaList;
vector<string> paramList;
SYMBOL_TABLE* symPtr;
bool printPrompt;

class Expression;
Expression* lastUsed;

void printRule(const char *, const char *);
int yyerror(const char *s);
void printTokenInfo(const char* tokenType, const char* lexeme);
void beginScope();
void endScope();
bool findEntryInAnyScope(const std::string theName);
TYPE_INFO& findEntryInAnyScopeTYPE(const std::string theName);

void valueAssignment(void*& leftValue, void* rightValue, int typeCode);
void printList(vector<TYPE_INFO> vec);
void outputValue(void const * const value, const int type);
void doAddition(TYPE_INFO& value, Expression* lhs, Expression* rhs);
void doMultiplication(TYPE_INFO& val, Expression* lhs, Expression* rhs);
void doSubtraction(TYPE_INFO& val, Expression* lhs, Expression* rhs);
void doDivision(TYPE_INFO& val, Expression* lhs, Expression* rhs);
void doModulous(TYPE_INFO& val, Expression* lhs, Expression* rhs);
void doPow(TYPE_INFO& val, Expression* lhs, Expression* rhs);
void doOr(TYPE_INFO& val, Expression* lhs, Expression* rhs);
void doAnd(TYPE_INFO& val, Expression* lhs, Expression* rhs);
void doNegate(string name);
void doNegate(TYPE_INFO& temp);
void doLT(TYPE_INFO& val, Expression* lhs, Expression* rhs);
void doLE(TYPE_INFO& val, Expression* lhs, Expression* rhs);
void doGT(TYPE_INFO& val, Expression* lhs, Expression* rhs);
void doGE(TYPE_INFO& val, Expression* lhs, Expression* rhs);
void doNE(TYPE_INFO& val, Expression* lhs, Expression* rhs);
void doEQ(TYPE_INFO& val, Expression* lhs, Expression* rhs);

#include "statement.h"

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
%type <typeInfo> N_CONST N_EXPR N_EXPR_LIST N_WHILE_EXPR N_ARITHLOGIC_EXPR N_ASSIGNMENT_EXPR N_OUTPUT_EXPR N_INPUT_EXPR N_LIST_EXPR N_FUNCTION_CALL N_FUNCTION_DEF N_QUIT_EXPR N_INDEX N_SINGLE_ELEMENT N_ENTIRE_VAR N_TERM N_MULT_OP_LIST N_FACTOR N_ADD_OP N_MULT_OP N_VAR N_SIMP_ARITHLOGIC N_ADD_OP_LIST N_FOR_EXPR N_IF_EXPR  N_PARAM_LIST N_ARG_LIST N_ARGS N_VALID_ASSIGN_EXPR N_DICT_EXPR N_FUNC_EXPR_LIST N_PROGRAM N_VALID_PRINT_EXPR N_REL_OP N_PAREN_EXPR N_CONST_LIST N_IND_EXPR N_VALID_IF_EXPR N_OPT_ELIF N_OPT_ELSE N_IF_BODY_EXPR N_IF_EXPR_LIST N_ELSE_EXPR_LIST N_ASSIGN_OP N_VALID_FOR_EXPR N_FOR_EXPR_LIST N_ATOM N_MULT_EXP_LIST N_OR_CHAIN N_OR_LIST N_AND_CHAIN N_AND_LIST N_COMP_CHAIN N_COMP_LIST N_WHILE_EXPR_LIST N_VALID_WHILE_EXP N_FUNC_BODY_EXPR N_ARG_EXPR N_V_PRINT_EXPR;

%start N_START

%%

N_START           : N_PROGRAM
                    {
                      // printRule("N_PROGRAM", "N_START");
                      endScope();
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
                      $1.stmt->eval();
                      if (printPrompt)
                        cout << ">>> ";
                    }
                  | N_WHILE_EXPR
                    {
                      // printRule("N_WHILE_EXPR", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      valueAssignment($$.value, $1.value, $1.type);
                      $1.stmt->eval();
                      if (printPrompt)
                        cout << ">>> ";
                    }
                  | N_FOR_EXPR
                    {
                      // printRule("N_FOR_EXPR", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      valueAssignment($$.value, $1.value, $1.type);
                      $1.stmt->eval();
                      if (printPrompt)
                        cout << ">>> ";
                    }
                  | N_ASSIGNMENT_EXPR
                    {
                      // printRule("N_ASSIGNMENT_EXPR", "N_EXPR");
                      $1.stmt->eval();
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      if (printPrompt)
                        cout << ">>> ";
                    }
                  | N_INPUT_EXPR
                    {
                      // printRule("N_INPUT_EXPR", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      TYPE_INFO temp = $1.expr->eval();
                      $1.value = new string("TEMP");
                      $1.type = STR;
                      valueAssignment($$.value, $1.value, $1.type);
                      outputValue(temp.value, STR);
                      if (printPrompt)
                        cout << ">>> ";
                    }
                  | N_ARITHLOGIC_EXPR
                    {
                      // printRule("N_ARITHLOGIC_EXPR", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      valueAssignment($$.value, $1.value, $1.type);
                      $1.stmt->eval();
                      if (printPrompt)
                        cout << ">>> ";
                    }
                  | N_OUTPUT_EXPR
                    {
                      // printRule("N_OUTPUT_EXPR", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      valueAssignment($$.value, $1.value, $1.type);
                      if ($1.type == INT)
                      {
                        cout << *(int*)($1.value) << endl;
                      }
                      else if ($1.type == FLOAT)
                      {
                        cout << *(float*)($1.value) << endl;
                      }
                      else if ($1.type == STR)
                      {
                        cout << *(string*)($1.value) << endl;
                      }
                      else if ($1.type == BOOL)
                      {
                        cout << *(bool*)($1.value) << endl;
                      }
                      else if ($1.type == LIST)
                      {
                        printList(*(vector<TYPE_INFO>*)($1.value));
                      }
                      if (printPrompt)
                        cout << ">>> ";
                    }
                  | N_FUNCTION_DEF
                    {
                      // printRule("N_FUNCTION_DEF", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      valueAssignment($$.value, $1.value, $1.type);
                      $1.stmt->eval();
                      if (printPrompt)
                        cout << ">>> ";
                    }
                  | N_LIST_EXPR
                    {
                      // printRule("N_LIST_EXPR", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      valueAssignment($$.value, $1.value, $1.type);
                      printList(*(vector<TYPE_INFO>*)($1.value));
                      if (printPrompt)
                        cout << "\n>>> ";
                    }
                  | N_DICT_EXPR
                    {
                      // printRule("N_DICT_EXPR", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      valueAssignment($$.value, $1.value, $1.type);
                      if (printPrompt)
                        cout << ">>> ";
                    }
                  | N_FUNCTION_CALL
                    {
                      // printRule("N_FUNCTION_CALL", "N_EXPR");
                      $$.numParams = $1.numParams;
                      $$.returnType = $1.returnType;
                      $$.isFuncParam = $1.isFuncParam;
                      valueAssignment($$.value, $1.value, $1.type);
                      $1.stmt->eval();
                      if (printPrompt)
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
                        $$.expr = $1.expr;
                      }
                    | N_ARITHLOGIC_EXPR
                      {
                        // printRule("N_ARITHLOGIC_EXPR", "N_VALID_ASSIGN_EXPR");
                        $$.type = $1.type;
                        $$.numParams = $1.numParams;
                        $$.returnType = $1.returnType;
                        $$.isFuncParam = $1.isFuncParam;
                        valueAssignment($$.value, $1.value, $1.type);
                        $$.expr = $1.expr;
                        $$.operand = NULLTYPE;
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
                        $$.stmt = new Assignment(*dynamic_cast<Assignment*>($1.stmt));
                        $$.type = $1.type;
                        $$.numParams = $1.numParams;
                        $$.returnType = $1.returnType;
                        $$.isFuncParam = $1.isFuncParam;
                        $$.expr = $1.stmt->getExpr();
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
                    ;
N_VALID_PRINT_EXPR  : N_V_PRINT_EXPR T_COMMA N_VALID_PRINT_EXPR
                      {
                        $$.stmt = new StatementList();
                        $$.stmt->add($3.stmt);
                        $$.stmt->add($1.stmt);
                      }
                    | N_V_PRINT_EXPR
                      {
                        $$.stmt = $1.stmt;
                      }
                    ;
N_V_PRINT_EXPR      : N_INPUT_EXPR
                      {
                        $$.type = $1.type;
                        valueAssignment($$.value, $1.value, $1.type);
                        $$.stmt = new ArithStatement($1.expr);
                      }
                    | N_ARITHLOGIC_EXPR
                      {
                        $$.type = $1.type;
                        valueAssignment($$.value, $1.value, $1.type);
                        $$.stmt = $1.stmt;
                      }
                    | N_LIST_EXPR
                      {
                        $$.type = $1.type;
                        valueAssignment($$.value, $1.value, $1.type);
                        $$.stmt = new ArithStatement($1.expr);
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
N_FUNC_EXPR_LIST  : T_NEWLINE N_FUNC_BODY_EXPR N_FUNC_EXPR_LIST
                    {
                      $$.stmt = new StatementList();
                      if ($3.type != UNDEF)
                        $$.stmt->append($3.stmt);
                      $$.stmt->add($2.stmt);
                    }
                  | T_NEWLINE N_FUNC_EXPR_LIST
                    {
                      $$.type = UNDEF;
                    }
                  | /* epsilon */
                    {
                      $$.type = UNDEF;
                    }
                  ;
N_FUNC_BODY_EXPR  : N_IF_EXPR
                    {
                      if (printPrompt)
                        cout << "... ";
                      $$.stmt = $1.stmt;
                    }
                  | N_WHILE_EXPR
                    {
                      if (printPrompt)
                        cout << "... ";
                      $$.stmt = new WhileLoop(*dynamic_cast<WhileLoop*>($1.stmt));
                    }
                  | N_FOR_EXPR
                    {
                      if (printPrompt)
                        cout << "... ";
                      $$.stmt = new ForLoop(*dynamic_cast<ForLoop*>($1.stmt));
                    }
                  | N_ARITHLOGIC_EXPR
                    {
                      if (printPrompt)
                        cout << "... ";
                      $$.stmt = new ArithStatement(*dynamic_cast<ArithStatement*>($1.stmt));
                    }
                  | N_ASSIGNMENT_EXPR
                    {
                      if (printPrompt)
                        cout << "... ";
                      $$.stmt = new Assignment(*dynamic_cast<Assignment*>($1.stmt));
                    }
                  | N_OUTPUT_EXPR
                    {
                      if (printPrompt)
                        cout << "... ";
                      $$.stmt = new Print($1.stmt);
                    }
                  | N_INPUT_EXPR
                    {
                      if (printPrompt)
                        cout << "... ";
                      $$.stmt = new ArithStatement($1.expr);
                    }
                  | N_LIST_EXPR
                    {
                      if (printPrompt)
                        cout << "... ";
                    }
                  | N_DICT_EXPR
                    {
                      if (printPrompt)
                        cout << "... ";
                    }
                  | N_FUNCTION_CALL
                    {
                      if (printPrompt)
                        cout << "... ";
                    }
                  | N_RETURN_EXPR
                    {

                    }
                  | N_QUIT_EXPR
                    {

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
                      if (printPrompt)
                        cout << "... ";
                      ifScopeRestore = ScopeStack;
                    }
                    N_IF_EXPR_LIST N_OPT_ELIF N_OPT_ELSE T_END
                    {
                      // printRule("T_IF N_EXPR T_COLON N_EXPR_LIST T_END", "N_IF_EXPR");
                      if (!(*(int*)($2.value)))
                        ScopeStack = ifScopeRestore;
                      else if ($7.type != UNDEF)
                        ScopeStack = elseScopeRestore;
                      if ($5.stmt != NULL && $7.stmt != NULL && $5.stmt->size() && $7.stmt->size())
                        $$.stmt = new IfElseStatement($2.expr, *dynamic_cast<StatementList*>($5.stmt), *dynamic_cast<StatementList*>($7.stmt));
                      else if ($5.stmt != NULL && $7.stmt == NULL && $5.stmt->size())
                        $$.stmt = new IfElseStatement($2.expr, *dynamic_cast<StatementList*>($5.stmt), StatementList());
                      else if ($5.stmt == NULL && $7.stmt != NULL && $7.stmt->size())
                        $$.stmt = new IfElseStatement($2.expr, StatementList(), *dynamic_cast<StatementList*>($7.stmt));
                      else
                        $$.stmt = new IfElseStatement($2.expr, StatementList(), StatementList());
                    }
                  ;
N_VALID_IF_EXPR   : N_ARITHLOGIC_EXPR
                    {
                      $$.type = $1.type;
                      valueAssignment($$.value, $1.value, $1.type);
                      $$.expr = $1.expr;
                    }
                  | N_LIST_EXPR
                    {
                      $$.type = BOOL;
                      if ((*(vector<TYPE_INFO>*)($1.value)).size() == 0)
                        $$.value = new bool(false);
                      else
                        $$.value = new bool(true);
                      $$.expr = $1.expr;
                    }
                  | N_DICT_EXPR
                    {
                      $$.type = $1.type;
                      valueAssignment($$.value, $1.value, $1.type);
                    }
                  | N_QUIT_EXPR
                    {
                      
                    }
                  ;
N_IF_EXPR_LIST    : T_NEWLINE N_IF_BODY_EXPR N_IF_EXPR_LIST
                    {
                      $$.stmt = new StatementList();
                      if ($3.type != UNDEF)
                        $$.stmt->append($3.stmt);
                      $$.stmt->add($2.stmt);
                    }
                  | T_NEWLINE N_IF_EXPR_LIST
                    {
                      $$.type = UNDEF;
                    }
                  | /* epsilon */
                    {
                      $$.type = UNDEF;
                    }
                  ;
N_IF_BODY_EXPR    : N_IF_EXPR
                    {
                      if (printPrompt)
                        cout << "... ";
                      $$.stmt = $1.stmt;
                    }
                  | N_WHILE_EXPR
                    {
                      if (printPrompt)
                        cout << "... ";
                      $$.stmt = new WhileLoop(*dynamic_cast<WhileLoop*>($1.stmt));
                    }
                  | N_FOR_EXPR
                    {
                      if (printPrompt)
                        cout << "... ";
                      $$.stmt = new ForLoop(*dynamic_cast<ForLoop*>($1.stmt));
                    }
                  | N_ARITHLOGIC_EXPR
                    {
                      if (printPrompt)
                        cout << "... ";
                      $$.stmt = new ArithStatement(*dynamic_cast<ArithStatement*>($1.stmt));
                    }
                  | N_ASSIGNMENT_EXPR
                    {
                      if (printPrompt)
                        cout << "... ";
                      $$.stmt = new Assignment(*dynamic_cast<Assignment*>($1.stmt));
                    }
                  | N_OUTPUT_EXPR
                    {
                      if (printPrompt)
                        cout << "... ";
                      $$.stmt = new Print($1.stmt);
                    }
                  | N_INPUT_EXPR
                    {
                      if (printPrompt)
                        cout << "... ";
                      $$.stmt = new ArithStatement($1.expr);
                    }
                  | N_LIST_EXPR
                    {
                      if (printPrompt)
                        cout << "... ";
                    }
                  | N_DICT_EXPR
                    {
                      if (printPrompt)
                        cout << "... ";
                    }
                  | N_FUNCTION_DEF
                    {
                      if (printPrompt)
                        cout << "... ";
                    }
                  | N_FUNCTION_CALL
                    {
                      if (printPrompt)
                        cout << "... ";
                    }
                  | N_QUIT_EXPR
                    {

                    }
                  ;
N_ELSE_EXPR_LIST  : T_NEWLINE N_IF_BODY_EXPR N_ELSE_EXPR_LIST
                    {
                      $$.stmt = new StatementList();
                      if ($3.type != UNDEF)
                        $$.stmt->append($3.stmt);
                      $$.stmt->add($2.stmt);
                    }
                  | T_NEWLINE N_ELSE_EXPR_LIST
                    {
                      $$.type = UNDEF;
                    }
                  | /* epsilon */
                    {
                      $$.type = UNDEF;
                    }
                  ;
N_OPT_ELIF        : T_ELIF N_VALID_IF_EXPR T_COLON
                    {
                      if (printPrompt)
                        cout << "... ";
                    } 
                    N_IF_EXPR_LIST N_OPT_ELIF
                    {
                      // printRule("T_ELIF N_EXPR T_COLON N_EXPR_LIST N_OPT_ELIF", "N_OPT_ELIF");
                    }
                  | /* epsilon */
                    {
                      // printRule("EPSILON", "N_OPT_ELIF");
                      $$.type = UNDEF;
                    }
                  ;
N_OPT_ELSE        : T_ELSE T_COLON
                    {
                      if (printPrompt)
                        cout << "... ";
                      elseScopeRestore = ScopeStack;
                    } 
                    N_ELSE_EXPR_LIST
                    {
                      // printRule("T_ELSE T_COLON N_EXPR_LIST", "N_OPT_ELSE");
                      $$.stmt = new StatementList();
                      if ($4.stmt != NULL)
                        $$.stmt->append($4.stmt);
                    }
                  | /* epsilon */
                    {
                      // printRule("EPSILON", "N_OPT_ELSE");
                      $$.type = UNDEF;
                      $$.stmt = new StatementList();
                    }
                  ;
N_WHILE_EXPR      : T_WHILE N_VALID_WHILE_EXP T_COLON
                    {
                      if (printPrompt)
                        cout << "... ";
                    } 
                    N_WHILE_EXPR_LIST T_END
                    {
                      // printRule("T_WHILE N_EXPR T_COLON N_EXPR_LIST T_END", "N_WHILE_EXPR");
                      $$.stmt = new WhileLoop($2.expr, *dynamic_cast<StatementList*>($5.stmt));
                    }
                  ;
N_VALID_WHILE_EXP : N_ARITHLOGIC_EXPR
                    {
                      $$.expr = $1.expr;
                    }
                  | N_LIST_EXPR
                    {
                      $$.expr = $1.expr;
                    }
                  ;
N_WHILE_EXPR_LIST : T_NEWLINE N_IF_BODY_EXPR N_WHILE_EXPR_LIST
                    {
                      $$.stmt = new StatementList();
                      if ($3.type != UNDEF)
                        $$.stmt->append($3.stmt);
                      $$.stmt->add($2.stmt);
                    }
                  | T_NEWLINE N_WHILE_EXPR_LIST
                    {
                      $$.type = UNDEF;
                    }
                  | /* epsilon */
                    {
                      $$.type = UNDEF;
                    }
                  ;
N_FOR_EXPR        : T_FOR T_IDENT
                    {
                      int tempType = ScopeStack.top().findEntry($2).type;
                      if (tempType == UNDEF)
                      {
                        TYPE_INFO temp;
                        temp.type = UNDEF;
                        temp.numParams = NOT_APPLICABLE;
                        temp.returnType = NOT_APPLICABLE;
                        temp.isFuncParam = false;
                        ScopeStack.top().addEntry(SYMBOL_TABLE_ENTRY($2, temp));
                      }
                    }
                    T_IN N_VALID_FOR_EXPR T_COLON
                    {
                      if (printPrompt)
                        cout << "... ";
                      if ((*(vector<TYPE_INFO>*)($5.value)).size() > 0)
                      {
                        ScopeStack.top().findEntry($2).type = (*(vector<TYPE_INFO>*)($5.value))[0].type;
                        valueAssignment(ScopeStack.top().findEntry($2).value, (*(vector<TYPE_INFO>*)($5.value))[0].value, (*(vector<TYPE_INFO>*)($5.value))[0].type);
                      }
                    }
                    N_FOR_EXPR_LIST T_END
                    {
                      // printRule("T_FOR T_IDENT T_IN N_EXPR T_COLON N_EXPR_LIST T_END", "N_FOR_EXPR");
                      $$.stmt = new ForLoop($2, ArithStatement($5.expr), *dynamic_cast<StatementList*>($8.stmt));
                    }
                  ;
N_FOR_EXPR_LIST   : T_NEWLINE N_IF_BODY_EXPR N_FOR_EXPR_LIST
                    {
                      $$.stmt = new StatementList();
                      if ($3.type != UNDEF)
                        $$.stmt->append($3.stmt);
                      $$.stmt->add($2.stmt);
                    }
                  | T_NEWLINE N_FOR_EXPR_LIST
                    {
                      $$.type = UNDEF;
                    }
                  | /* epsilon */
                    {
                      $$.type = UNDEF;
                    }
                  ;
N_VALID_FOR_EXPR  : N_LIST_EXPR
                    {
                      $$.type = LIST;
                      $$.value = new vector<TYPE_INFO>(*(vector<TYPE_INFO>*)($1.value));
                      $$.expr = $1.expr;
                    }
                  | N_VAR
                    {
                      if ($1.type != LIST)
                        yyerror("Must have iterable list");
                      $$.type = LIST;
                      $$.value = new vector<TYPE_INFO>(*(vector<TYPE_INFO>*)($1.value));
                      $$.expr = $1.expr;
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
                            temp.type = INT;
                            temp.numParams = NOT_APPLICABLE;
                            temp.returnType = NOT_APPLICABLE;
                            temp.isFuncParam = false;
                            ScopeStack.top().addEntry(SYMBOL_TABLE_ENTRY($1, temp));
                        }
                      }
                    }
                    N_ASSIGN_OP N_VALID_ASSIGN_EXPR
                    {
                      $$.stmt = new Assignment($1, $4.type, $2, $5.expr);
                      $$.type = $5.type;
                      if ($5.stmt != NULL)
                      {
                        if ($5.stmt->size() != -1)
                        {
                          $$.stmt->add($5.stmt);
                          $$.stmt->append($5.stmt);
                        }
                      }
                      if ($5.type == INT)
                      {
                        $$.value = new int(*(int*)($5.value));
                      }
                      else if ($5.type == FLOAT)
                      {
                        $$.value = new float(*(float*)($5.value));
                      }
                      else if ($5.type == BOOL)
                      {
                        $$.value = new bool(*(bool*)($5.value));
                      }
                      else if ($5.type == STR)
                      {
                        $$.value = new string(*(string*)($5.value));
                      }
                      else if ($5.type == LIST)
                      {
                        $$.value = new vector<TYPE_INFO>(*(vector<TYPE_INFO>*)($5.value));
                      }
                      if (ScopeStack.top().findEntry($1).type == UNDEF && $5.type == STR)
                      {
                        ScopeStack.top().findEntry($1).type = STR;
                        ScopeStack.top().findEntry($1).value = new string("TEMP");
                      }
                      else if (ScopeStack.top().findEntry($1).type == UNDEF && $5.type == INT)
                      {
                        ScopeStack.top().findEntry($1).type = INT;
                        ScopeStack.top().findEntry($1).value = new int(0);
                      }
                      else if (ScopeStack.top().findEntry($1).type == UNDEF && $5.type == FLOAT)
                      {
                        ScopeStack.top().findEntry($1).type = FLOAT;
                        ScopeStack.top().findEntry($1).value = new float(0);
                      }
                      else if (ScopeStack.top().findEntry($1).type == UNDEF && $5.type == BOOL)
                      {
                        ScopeStack.top().findEntry($1).type = BOOL;
                        ScopeStack.top().findEntry($1).value = new bool(0);
                      }
                      else if (ScopeStack.top().findEntry($1).type == UNDEF && $5.type == LIST)
                      {
                        ScopeStack.top().findEntry($1).type = LIST;
                        ScopeStack.top().findEntry($1).value = new vector<TYPE_INFO>();
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
                      $$.expr = new Input();
                    }
                  | T_READ T_LPAREN N_ARITHLOGIC_EXPR T_RPAREN
                    {
                      $$.expr = new Input($3.expr);
                    }
                  ;
N_OUTPUT_EXPR     : T_PRINT N_VALID_PRINT_EXPR
                    {
                      // printRule("T_PRINT N_VALID_PRINT_EXPR", "N_OUTPUT_EXPR");
                      $$.type = $2.type;
                      if ($2.type == INT)
                      {
                        $$.value = new int(*(int*)($2.value));
                      }
                      else if ($2.type == FLOAT)
                      {
                        $$.value = new float(*(float*)($2.value));
                      }
                      else if ($2.type == STR)
                      {
                        $$.value = new string(*(string*)($2.value));
                      }
                      else if ($2.type == BOOL)
                      {
                        $$.value = new bool(*(bool*)($2.value));
                      }
                      else if ($2.type == LIST)
                      {
                        $$.value = new vector<TYPE_INFO>(*(vector<TYPE_INFO>*)($2.value));
                      }
                      $$.stmt = $2.stmt;
                    }
                  | T_PRINT
                    {
                      // printRule("T_PRINT", "N_OUTPUT_EXPR");
                      $$.type = STR;
                      $$.value = new string("");
                      $$.stmt = new ArithStatement(new Const($$));
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
                    T_RPAREN T_COLON
                    {
                      if (printPrompt)
                        cout << "... ";
                    }
                    N_FUNC_EXPR_LIST T_END
                    {
                      // printRule("T_DEF T_IDENT T_LPAREN N_PARAM_LIST T_RPAREN T_COLON N_FUNC_EXPR_LIST T_END", "N_FUNCTION_DEF");
                      if ($11.type == FUNCTION)
                        yyerror("Arg 2 cannot be function");
                      $$.type = FUNCTION;
                      $$.numParams = $6.numParams;
                      $$.returnType = $11.type;
                      if (symPtr != NULL)
                      {
                        if (symPtr->findEntry($2).type != UNDEF)
                        {
                          symPtr->findEntry($2).type = FUNCTION;
                          symPtr->findEntry($2).numParams = $6.numParams;
                          symPtr->findEntry($2).returnType = $11.type;
                          symPtr->findEntry($2).isFuncParam = false;
                        }
                        else
                        {
                          TYPE_INFO temp;
                          temp.type = FUNCTION;
                          temp.numParams = $6.numParams;
                          temp.returnType = $11.type;
                          temp.isFuncParam = false;
                          symPtr->addEntry(SYMBOL_TABLE_ENTRY($2, temp));
                        }
                      }
                      $$.stmt = new FunctionDef($2, paramList, *dynamic_cast<StatementList*>($11.stmt));
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
                        temp.value = new int(1);
                        temp.numParams = NOT_APPLICABLE;
                        temp.returnType = NOT_APPLICABLE;
                        temp.isFuncParam = true;
                        ScopeStack.top().addEntry(SYMBOL_TABLE_ENTRY($1, temp));
                        paramList.insert(paramList.begin(), $1);
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
                        temp.value = new int(1);
                        temp.numParams = NOT_APPLICABLE;
                        temp.returnType = NOT_APPLICABLE;
                        temp.isFuncParam = true;
                        ScopeStack.top().addEntry(SYMBOL_TABLE_ENTRY($1, temp));
                        paramList.insert(paramList.begin(), $1);
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
                      $$.expr = new Const($$);
                      metaList.clear();
                    }
                  | T_LBRACKET N_CONST_LIST T_RBRACKET
                    {
                      // printRule(" T_RBRACKET N_CONST_LIST T_LBRACKET", "N_LIST_EXPR");
                      $$.type = LIST;
                      $$.numParams = NOT_APPLICABLE;
                      $$.returnType = NOT_APPLICABLE;
                      $$.value = new vector<TYPE_INFO>(*(vector<TYPE_INFO>*)($2.value));
                      $$.expr = new Const($$);
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
                      (dynamic_cast<FunctionDef*>(findEntryInAnyScopeTYPE($1).stmt))->setParams(metaList);
                      $$.stmt = new FunctionCall($1);
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
N_ARGS            : N_ARG_EXPR
                    {
                      // printRule("N_EXPR", "N_ARGS");
                      $$.numParams = 1;
                      metaList.insert(metaList.begin(), $1.expr->eval());
                    }
                  | N_ARG_EXPR T_COMMA N_ARGS
                    {
                      // printRule("N_EXPR T_COMMA N_ARGS", "N_ARGS");
                      $$.numParams = 1 + $3.numParams;
                      metaList.insert(metaList.begin(), $1.expr->eval());
                    }
                  ;
N_ARG_EXPR        : N_ARITHLOGIC_EXPR
                    {
                      $$.expr = $1.expr;
                    }
                  | N_LIST_EXPR
                    {
                      $$.expr = $1.expr;
                    }
                  ;
N_QUIT_EXPR       : T_QUIT T_LPAREN T_RPAREN
                    {
                      // printRule("T_QUIT T_LPAREN T_RPAREN", "N_QUIT_EXPR");
                      exit(0);
                    }
                  ;
N_ARITHLOGIC_EXPR : N_OR_CHAIN
                    {
                      $$.stmt = new ArithStatement($1.expr);
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
                  ;
N_OR_CHAIN        : N_AND_CHAIN N_OR_LIST
                    {
                      if ($2.type != UNDEF)
                      {
                        if ($1.type == STR && $2.type != STR || $1.type != STR && $2.type == STR)
                        yyerror("Incompatible types of int and str");
                        $2.expr->setRhs($1.expr);
                        $$.expr = $2.expr;
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
                        $$.expr = $1.expr;
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
N_OR_LIST         : T_OR N_AND_CHAIN N_OR_LIST
                    {
                      if ($3.type != UNDEF)
                      {
                        $$.operand = OR;
                        $3.expr->setRhs($2.expr);
                        $$.expr = new Or($3.expr, nullptr);
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
                        $$.operand = OR;
                        $$.expr = new Or($2.expr, nullptr);
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
                      $$.type = UNDEF;
                    }
                  ;
N_AND_CHAIN       : N_COMP_CHAIN N_AND_LIST
                    {
                      // printRule("TERM", "FACTOR MULT_OP_LIST");
                      if ($2.type == UNDEF)
                      {
                        $$.type = $1.type;
                        $$.expr = $1.expr;
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
                        if ($1.type == STR && $2.type != STR || $1.type != STR && $2.type == STR)
                        yyerror("Incompatible types of int and str");
                        if ($2.expr->getRhs() == nullptr)
                          $2.expr->setRhs($1.expr);
                        else
                          $2.expr->setLhs($1.expr);
                        $$.expr = $2.expr;
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
                    }
                  ;
N_AND_LIST        : T_AND N_COMP_CHAIN N_AND_LIST
                    {
                      // printRule("MULT_OP_LIST", "MULT_OP FACTOR MULT_OP_LIST");
                      if ($3.type != UNDEF)
                      {
                        $$.operand = AND;
                        if ($3.expr->getRhs() == nullptr)
                          $3.expr->setRhs($2.expr);
                        else
                          $3.expr->setLhs($2.expr);
                        $$.expr = $3.expr;
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
                      else
                      {
                        $$.expr = new And($2.expr, nullptr);
                        if ($2.type == INT)
                        {
                          $$.value = new int(*(int*)($2.value));
                          $$.operand = AND;
                          $$.type = $2.type;
                        }
                        else if ($2.type == FLOAT)
                        {
                          $$.value = new float(*(float*)($2.value));
                          $$.operand = AND;
                          $$.type = $2.type;
                        }
                        else
                        {
                          $$.value = new bool(*(bool*)($2.value));
                          $$.operand = AND;
                          $$.type = $2.type;
                        }
                      }
                    }
                  | /* epsilon */
                    {
                      $$.type = UNDEF;
                    }
                  ;
N_COMP_CHAIN      : N_SIMP_ARITHLOGIC N_COMP_LIST
                    {
                      if ($2.type != UNDEF)
                      {
                        if ($1.type == STR && $2.type != STR || $1.type != STR && $2.type == STR)
                        yyerror("Incompatible types of int and str");
                        if (lastUsed->getRhs() == nullptr)
                          lastUsed->setRhs($1.expr);
                        else
                          lastUsed->setLhs($1.expr);
                        $$.expr = $2.expr;
                        $$.type = BOOL;
                        if ($2.operand == LT)
                        {
                          if ($1.type == INT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool(*(int*)($1.value) < *(int*)($2.value));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool(*(int*)($1.value) < *(float*)($2.value));
                            }
                            else
                            {
                              $$.value = new bool(*(int*)($1.value) < *(bool*)($2.value));
                            }
                          }
                          else if ($1.type == FLOAT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool(*(float*)($1.value) < *(int*)($2.value));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool(*(float*)($1.value) < *(float*)($2.value));
                            }
                            else
                            {
                              $$.value = new bool(*(float*)($1.value) < *(bool*)($2.value));
                            }
                          }
                          else
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool(*(bool*)($1.value) < *(int*)($2.value));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool(*(bool*)($1.value) < *(float*)($2.value));
                            }
                            else
                            {
                              $$.value = new bool(*(bool*)($1.value) < *(bool*)($2.value));
                            }
                          }
                        }
                        else if ($2.operand == GT)
                        {
                          if ($1.type == INT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool(*(int*)($1.value) > *(int*)($2.value));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool(*(int*)($1.value) > *(float*)($2.value));
                            }
                            else
                            {
                              $$.value = new bool(*(int*)($1.value) > *(bool*)($2.value));
                            }
                          }
                          else if ($1.type == FLOAT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool(*(float*)($1.value) > *(int*)($2.value));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool(*(float*)($1.value) > *(float*)($2.value));
                            }
                            else
                            {
                              $$.value = new bool(*(float*)($1.value) > *(bool*)($2.value));
                            }
                          }
                          else
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool(*(bool*)($1.value) > *(int*)($2.value));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool(*(bool*)($1.value) > *(float*)($2.value));
                            }
                            else
                            {
                              $$.value = new bool(*(bool*)($1.value) > *(bool*)($2.value));
                            }
                          }
                        }
                        else if ($2.operand == EQ)
                        {
                          if ($1.type == INT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool(*(int*)($1.value) == *(int*)($2.value));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool(*(int*)($1.value) == *(float*)($2.value));
                            }
                            else
                            {
                              $$.value = new bool(*(int*)($1.value) == *(bool*)($2.value));
                            }
                          }
                          else if ($1.type == FLOAT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool(*(float*)($1.value) == *(int*)($2.value));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool(*(float*)($1.value) == *(float*)($2.value));
                            }
                            else
                            {
                              $$.value = new bool(*(float*)($1.value) == *(bool*)($2.value));
                            }
                          }
                          else if ($1.type == BOOL)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool(*(bool*)($1.value) == *(int*)($2.value));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool(*(bool*)($1.value) == *(float*)($2.value));
                            }
                            else
                            {
                              $$.value = new bool(*(bool*)($1.value) == *(bool*)($2.value));
                            }
                          }
                          else
                          {
                            $$.value = new bool((*(string*)($1.value)) == (*(string*)($2.value)));
                          }
                        }
                        else if ($2.operand == LE)
                        {
                          if ($1.type == INT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool(*(int*)($1.value) <= *(int*)($2.value));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool(*(int*)($1.value) <= *(float*)($2.value));
                            }
                            else
                            {
                              $$.value = new bool(*(int*)($1.value) <= *(bool*)($2.value));
                            }
                          }
                          else if ($1.type == FLOAT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool(*(float*)($1.value) <= *(int*)($2.value));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool(*(float*)($1.value) <= *(float*)($2.value));
                            }
                            else
                            {
                              $$.value = new bool(*(float*)($1.value) <= *(bool*)($2.value));
                            }
                          }
                          else
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool(*(bool*)($1.value) <= *(int*)($2.value));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool(*(bool*)($1.value) <= *(float*)($2.value));
                            }
                            else
                            {
                              $$.value = new bool(*(bool*)($1.value) <= *(bool*)($2.value));
                            }
                          }
                        }
                        else if ($2.operand == GE)
                        {
                          if ($1.type == INT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool(*(int*)($1.value) >= *(int*)($2.value));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool(*(int*)($1.value) >= *(float*)($2.value));
                            }
                            else
                            {
                              $$.value = new bool(*(int*)($1.value) >= *(bool*)($2.value));
                            }
                          }
                          else if ($1.type == FLOAT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool(*(float*)($1.value) >= *(int*)($2.value));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool(*(float*)($1.value) >= *(float*)($2.value));
                            }
                            else
                            {
                              $$.value = new bool(*(float*)($1.value) >= *(bool*)($2.value));
                            }
                          }
                          else
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool(*(bool*)($1.value) >= *(int*)($2.value));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool(*(bool*)($1.value) >= *(float*)($2.value));
                            }
                            else
                            {
                              $$.value = new bool(*(bool*)($1.value) >= *(bool*)($2.value));
                            }
                          }
                        }
                        else if ($2.operand == NE)
                        {
                          if ($1.type == INT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool(*(int*)($1.value) != *(int*)($2.value));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool(*(int*)($1.value) != *(float*)($2.value));
                            }
                            else
                            {
                              $$.value = new bool(*(int*)($1.value) != *(bool*)($2.value));
                            }
                          }
                          else if ($1.type == FLOAT)
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool(*(float*)($1.value) != *(int*)($2.value));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool(*(float*)($1.value) != *(float*)($2.value));
                            }
                            else
                            {
                              $$.value = new bool(*(float*)($1.value) != *(bool*)($2.value));
                            } 
                          }
                          else
                          {
                            if ($2.type == INT)
                            {
                              $$.value = new bool(*(bool*)($1.value) != *(int*)($2.value));
                            }
                            else if ($2.type == FLOAT)
                            {
                              $$.value = new bool(*(bool*)($1.value) != *(float*)($2.value));
                            }
                            else
                            {
                              $$.value = new bool(*(bool*)($1.value) != *(bool*)($2.value));
                            }
                          }
                        }
                      }
                      else
                      {
                        $$.expr = $1.expr;
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
                    }
                  ;
N_COMP_LIST       : N_REL_OP N_SIMP_ARITHLOGIC N_COMP_LIST
                    {
                      if ($3.type != UNDEF)
                      {
                        $$.operand = $1.type;
                        lastUsed->setLhs($2.expr);
                        if ($1.type == LT)
                          $3.expr = new And(new lessThan(nullptr, $2.expr), $3.expr);
                        else if ($1.type == LE)
                          $3.expr = new And(new lessEq(nullptr, $2.expr), $3.expr);
                        else if ($1.type == GT)
                          $3.expr = new And(new greaterThan(nullptr, $2.expr), $3.expr);
                        else if ($1.type == GE)
                          $3.expr = new And(new greaterEq(nullptr, $2.expr), $3.expr);
                        else if ($1.type == EQ)
                          $3.expr = new And(new isEq(nullptr, $2.expr), $3.expr);
                        else if ($1.type == NE)
                          $3.expr = new And(new notEq(nullptr, $2.expr), $3.expr);
                        lastUsed = $3.expr->getLhs();
                        $$.expr = $3.expr;
                        $$.type = BOOL;
                        if ($3.operand == LT)
                        {
                          if ($2.type == INT)
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool(*(int*)($2.value) < *(int*)($3.value));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool(*(int*)($2.value) < *(float*)($3.value));
                            }
                            else
                            {
                              $$.value = new bool(*(int*)($2.value) < *(bool*)($3.value));
                            }
                          }
                          else if ($2.type == FLOAT)
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool(*(float*)($2.value) < *(int*)($3.value));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool(*(float*)($2.value) < *(float*)($3.value));
                            }
                            else
                            {
                              $$.value = new bool(*(float*)($2.value) < *(bool*)($3.value));
                            }
                          }
                          else
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool(*(bool*)($2.value) < *(int*)($3.value));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool(*(bool*)($2.value) < *(float*)($3.value));
                            }
                            else
                            {
                              $$.value = new bool(*(bool*)($2.value) < *(bool*)($3.value));
                            }
                          }
                        }
                        else if ($3.operand == GT)
                        {
                          if ($2.type == INT)
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool(*(int*)($2.value) > *(int*)($3.value));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool(*(int*)($2.value) > *(float*)($3.value));
                            }
                            else
                            {
                              $$.value = new bool(*(int*)($2.value) > *(bool*)($3.value));
                            }
                          }
                          else if ($2.type == FLOAT)
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool(*(float*)($2.value) > *(int*)($3.value));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool(*(float*)($2.value) > *(float*)($3.value));
                            }
                            else
                            {
                              $$.value = new bool(*(float*)($2.value) > *(bool*)($3.value));
                            }
                          }
                          else
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool(*(bool*)($2.value) > *(int*)($3.value));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool(*(bool*)($2.value) > *(float*)($3.value));
                            }
                            else
                            {
                              $$.value = new bool(*(bool*)($2.value) > *(bool*)($3.value));
                            }
                          }
                        }
                        else if ($3.operand == EQ)
                        {
                          if ($2.type == INT)
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool(*(int*)($2.value) == *(int*)($3.value));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool(*(int*)($2.value) == *(float*)($3.value));
                            }
                            else
                            {
                              $$.value = new bool(*(int*)($2.value) == *(bool*)($3.value));
                            }
                          }
                          else if ($2.type == FLOAT)
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool(*(float*)($2.value) == *(int*)($3.value));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool(*(float*)($2.value) == *(float*)($3.value));
                            }
                            else
                            {
                              $$.value = new bool(*(float*)($2.value) == *(bool*)($3.value));
                            }
                          }
                          else
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool(*(bool*)($2.value) == *(int*)($3.value));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool(*(bool*)($2.value) == *(float*)($3.value));
                            }
                            else
                            {
                              $$.value = new bool(*(bool*)($2.value) == *(bool*)($3.value));
                            }
                          }
                        }
                        else if ($3.operand == LE)
                        {
                          if ($2.type == INT)
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool(*(int*)($2.value) <= *(int*)($3.value));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool(*(int*)($2.value) <= *(float*)($3.value));
                            }
                            else
                            {
                              $$.value = new bool(*(int*)($2.value) <= *(bool*)($3.value));
                            }
                          }
                          else if ($2.type == FLOAT)
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool(*(float*)($2.value) <= *(int*)($3.value));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool(*(float*)($2.value) <= *(float*)($3.value));
                            }
                            else
                            {
                              $$.value = new bool(*(float*)($2.value) <= *(bool*)($3.value));
                            }
                          }
                          else
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool(*(bool*)($2.value) <= *(int*)($3.value));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool(*(bool*)($2.value) <= *(float*)($3.value));
                            }
                            else
                            {
                              $$.value = new bool(*(bool*)($2.value) <= *(bool*)($3.value));
                            }
                          }
                        }
                        else if ($3.operand == GE)
                        {
                          if ($2.type == INT)
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool(*(int*)($2.value) >= *(int*)($3.value));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool(*(int*)($2.value) >= *(float*)($3.value));
                            }
                            else
                            {
                              $$.value = new bool(*(int*)($2.value) >= *(bool*)($3.value));
                            }
                          }
                          else if ($2.type == FLOAT)
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool(*(float*)($2.value) >= *(int*)($3.value));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool(*(float*)($2.value) >= *(float*)($3.value));
                            }
                            else
                            {
                              $$.value = new bool(*(float*)($2.value) >= *(bool*)($3.value));
                            }
                          }
                          else
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool(*(bool*)($2.value) >= *(int*)($3.value));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool(*(bool*)($2.value) >= *(float*)($3.value));
                            }
                            else
                            {
                              $$.value = new bool(*(bool*)($2.value) >= *(bool*)($3.value));
                            }
                          }
                        }
                        else if ($3.operand == NE)
                        {
                          if ($2.type == INT)
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool(*(int*)($2.value) != *(int*)($3.value));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool(*(int*)($2.value) != *(float*)($3.value));
                            }
                            else
                            {
                              $$.value = new bool(*(int*)($2.value) != *(bool*)($3.value));
                            }
                          }
                          else if ($2.type == FLOAT)
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool(*(float*)($2.value) != *(int*)($3.value));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool(*(float*)($2.value) != *(float*)($3.value));
                            }
                            else
                            {
                              $$.value = new bool(*(float*)($2.value) != *(bool*)($3.value));
                            } 
                          }
                          else
                          {
                            if ($3.type == INT)
                            {
                              $$.value = new bool(*(bool*)($2.value) != *(int*)($3.value));
                            }
                            else if ($3.type == FLOAT)
                            {
                              $$.value = new bool(*(bool*)($2.value) != *(float*)($3.value));
                            }
                            else
                            {
                              $$.value = new bool(*(bool*)($2.value) != *(bool*)($3.value));
                            }
                          }
                        }
                      }
                      else
                      {
                        $$.operand = $1.type;
                        if ($1.type == LT)
                          $$.expr = new lessThan(nullptr, $2.expr);
                        else if ($1.type == LE)
                          $$.expr = new lessEq(nullptr, $2.expr);
                        else if ($1.type == GT)
                          $$.expr = new greaterThan(nullptr, $2.expr);
                        else if ($1.type == GE)
                          $$.expr = new greaterEq(nullptr, $2.expr);
                        else if ($1.type == EQ)
                          $$.expr = new isEq(nullptr, $2.expr);
                        else if ($1.type == NE)
                          $$.expr = new notEq(nullptr, $2.expr);
                        lastUsed = $$.expr;
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
                        else if ($2.type == BOOL)
                        {
                          $$.value = new bool(*(bool*)($2.value));
                          $$.type = $2.type;
                        }
                        else if ($2.type == STR)
                        {
                          $$.value = new std::string(*(std::string*)($2.value));
                          $$.type = STR;
                        }
                      }
                    }
                  | /* epsilon */
                    {
                      $$.type = UNDEF;
                    }
                  ;
N_SIMP_ARITHLOGIC : N_TERM N_ADD_OP_LIST
                    {
                      if ($2.type != UNDEF)
                      {
                        if ($1.type == STR && $2.type != STR || $1.type != STR && $2.type == STR)
                        yyerror("Incompatible types of int and str");
                        $2.expr->setRhs($1.expr);
                        $$.expr = $2.expr;
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
                      if ($3.type != UNDEF)
                      {
                        $$.operand = $1.type;
                        if ($1.type == ADD)
                        {
                          $3.expr->setRhs($2.expr);
                          $$.expr = new Addition($3.expr, nullptr);
                        }
                        else if ($1.type == SUB)
                        {
                          $3.expr->setRhs(new Neg($2.expr));
                          $$.expr = new Addition($3.expr, nullptr);
                        }
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
                        if ($1.type == ADD)
                          $$.expr = new Addition($2.expr, nullptr);
                        else if ($1.type == SUB)
                          $$.expr = new Addition(new Neg($2.expr), nullptr);
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
N_TERM            : N_ATOM N_MULT_OP_LIST
                    {
                      // printRule("TERM", "FACTOR MULT_OP_LIST");
                      if ($2.type == UNDEF)
                      {
                        $$.expr = $1.expr;
                        // $$.type = $1.type;
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
                        if ($1.type == STR && $2.type != STR || $1.type != STR && $2.type == STR)
                        yyerror("Incompatible types of int and str");
                        if (lastUsed->getRhs() == nullptr)
                          lastUsed->setRhs($1.expr);
                        else
                          lastUsed->setLhs($1.expr);
                        $$.expr = $2.expr;
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
N_MULT_OP_LIST    : N_MULT_OP N_ATOM N_MULT_OP_LIST
                    {
                    // printRule("MULT_OP_LIST", "MULT_OP FACTOR MULT_OP_LIST");
                    if ($3.type != UNDEF)
                    {
                      $$.operand = $1.type;
                      if (lastUsed->getRhs() == nullptr)
                      {
                        if ($1.type == MULT)
                          lastUsed->setRhs(new Multiplication($2.expr, nullptr));
                        else if ($1.type == DIV)
                          lastUsed->setRhs(new Division(nullptr, $2.expr));
                        else if ($1.type == MOD)
                          lastUsed->setRhs(new Modulous(nullptr, $2.expr));
                        lastUsed = lastUsed->getRhs();
                      }
                      else
                      {
                        if ($1.type == MULT)
                          lastUsed->setLhs(new Multiplication($2.expr, nullptr));
                        else if ($1.type == DIV)
                          lastUsed->setLhs(new Division(nullptr, $2.expr));
                        else if ($1.type == MOD)
                          lastUsed->setLhs(new Modulous(nullptr, $2.expr));
                        lastUsed = lastUsed->getLhs();
                      }
                      $$.expr = $3.expr;
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
                      if ($1.type == MULT)
                        $$.expr = new Multiplication($2.expr, nullptr);
                      else if ($1.type == DIV)
                        $$.expr = new Division(nullptr, $2.expr);
                      else if ($1.type == MOD)
                        $$.expr = new Modulous(nullptr, $2.expr);
                      lastUsed = $$.expr;
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
N_ATOM            : N_FACTOR N_MULT_EXP_LIST
                    {
                      if ($2.type == UNDEF)
                      {
                        $$.expr = $1.expr;
                        // $$.type = $1.type;
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
                        if ($1.type == STR && $2.type != STR || $1.type != STR && $2.type == STR)
                        yyerror("Incompatible types of int and str");
                        if ($2.expr->getRhs() == nullptr)
                          $2.expr->setRhs($1.expr);
                        else
                          $2.expr->setLhs($1.expr);
                        $$.expr = $2.expr;
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
                  ;
N_MULT_EXP_LIST   : T_POW N_FACTOR N_MULT_EXP_LIST
                    {
                    // printRule("MULT_OP_LIST", "MULT_OP FACTOR MULT_OP_LIST");
                    if ($3.type != UNDEF)
                    {
                      $$.operand = POW;
                      if ($3.expr->getRhs() == nullptr)
                        $3.expr->setRhs($2.expr);
                      else
                        $3.expr->setLhs($2.expr);
                      $$.expr = new Exponent(nullptr, $3.expr);
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
                    else
                    {
                      $$.expr = new Exponent(nullptr, $2.expr);
                      if ($2.type == INT)
                      {
                        $$.value = new int(*(int*)($2.value));
                        $$.operand = POW;
                        $$.type = $2.type;
                      }
                      else if ($2.type == FLOAT)
                      {
                        $$.value = new float(*(float*)($2.value));
                        $$.operand = POW;
                        $$.type = $2.type;
                      }
                      else
                      {
                        $$.value = new bool(*(bool*)($2.value));
                        $$.operand = POW;
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
                      $$.expr = $1.expr;
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
                  | N_CONST
                    {
                      // printRule("FACTOR", "CONST");
                      $$.type = $1.type;
                      TYPE_INFO temp;
                      temp.type = $1.type;
                      temp.value = $1.value;
                      $$.expr = new Const(temp);
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
                  | T_LPAREN N_PAREN_EXPR T_RPAREN
                    {
                      // printRule("FACTOR", "( EXPR )");
                      $$.type = $2.type;
                      $$.expr = $2.expr;
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
                      $$.expr = new Not($2.expr);
                    }
                  ;
N_PAREN_EXPR      : N_ARITHLOGIC_EXPR
                    {
                      $$.type = $1.type;
                      $$.expr = $1.expr;
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
                    {}
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
                  | T_MOD
                    {
                    // printRule("MULT_OP", "%%");
                    $$.type = MOD;
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
                      $$.type = ASSIGN;
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
                      $$.expr = new Var(*dynamic_cast<Var*>($1.expr));
                    }
                  | N_SINGLE_ELEMENT
                    {
                      // printRule("N_SINGLE_ELEMENT", "N_VAR");
                      $$.type = $1.type;
                      $$.expr = $1.expr;
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
                      $$.expr = new IndVar($1, $3);
                    }
                  ;
N_ENTIRE_VAR      : T_IDENT
                    {
                      // printRule("ENTIRE_VAR", "IDENT");
                      if (!findEntryInAnyScope($1))
                        yyerror("Undefined identifier");
                      
                      $$.expr = new Var($1);
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
  TYPE_INFO& type = ScopeStack.top( ).findEntry(theName);
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

void valueAssignment(void*& leftValue, void* rightValue, int typeCode)
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
    cout << "\'" << *(std::string*)(value) << "\'" << endl;
  }
  else if (type == BOOL)
  {
    cout << ((*(bool*)(value)) ? "True" : "False") << endl;
  }
  else if (type == LIST)
  {
    printList(*(vector<TYPE_INFO>*)(value));
    cout << endl;
  }
}

void doAddition(TYPE_INFO& val, Expression* lhs, Expression* rhs)
{
  TYPE_INFO lhsVal = lhs->eval(), rhsVal = rhs->eval();
  if (lhsVal.type == INT)
  {
    if (rhsVal.type == INT)
    {
      val.value = new int((*(int*)(lhsVal.value)) + (*(int*)(rhsVal.value)));
      val.type = INT;
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new float((*(int*)(lhsVal.value)) + (*(float*)(rhsVal.value)));
      val.type = FLOAT;
    }
    else
    {
      val.value = new int((*(int*)(lhsVal.value)) + (*(bool*)(rhsVal.value)));
      val.type = INT;
    }
  }
  else if (lhsVal.type == FLOAT)
  {
    val.type = FLOAT;
    if (rhsVal.type == INT)
    {
      val.value = new float((*(float*)(lhsVal.value)) + (*(int*)(rhsVal.value)));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new float((*(float*)(lhsVal.value)) + (*(float*)(rhsVal.value)));
    }
    else
    {
      val.value = new float((*(float*)(lhsVal.value)) + (*(bool*)(rhsVal.value)));
    }
  }
  else
  {
    if (rhsVal.type == INT)
    {
      val.value = new int((*(bool*)(lhsVal.value)) + (*(int*)(rhsVal.value)));
      val.type = INT;
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new float((*(bool*)(lhsVal.value)) + (*(float*)(rhsVal.value)));
      val.type = FLOAT;
    }
    else
    {
      val.value = new int((*(bool*)(lhsVal.value)) + (*(bool*)(rhsVal.value)));
      val.type = INT;
    }
  }
}

void doMultiplication(TYPE_INFO& val, Expression* lhs, Expression* rhs)
{
  TYPE_INFO lhsVal = lhs->eval(), rhsVal = rhs->eval();
  if (lhsVal.type == INT)
  {
    if (rhsVal.type == INT)
    {
      val.value = new int((*(int*)(lhsVal.value)) * (*(int*)(rhsVal.value)));
      val.type = INT;
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new float((*(int*)(lhsVal.value)) * (*(float*)(rhsVal.value)));
      val.type = FLOAT;
    }
    else
    {
      val.value = new int((*(int*)(lhsVal.value)) * (*(bool*)(rhsVal.value)));
      val.type = INT;
    }
  }
  else if (lhsVal.type == FLOAT)
  {
    if (rhsVal.type == INT)
    {
      val.value = new float((*(float*)(lhsVal.value)) * (*(int*)(rhsVal.value)));
      val.type = FLOAT;
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new float((*(float*)(lhsVal.value)) * (*(float*)(rhsVal.value)));
      val.type = FLOAT;
    }
    else
    {
      val.value = new float((*(float*)(lhsVal.value)) * (*(bool*)(rhsVal.value)));
      val.type = FLOAT;
    }
  }
  else
  {
    if (rhsVal.type == INT)
    {
      val.value = new int((*(bool*)(lhsVal.value)) * (*(int*)(rhsVal.value)));
      val.type = INT;
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new float((*(bool*)(lhsVal.value)) * (*(float*)(rhsVal.value)));
      val.type = FLOAT;
    }
    else
    {
      val.value = new bool((*(bool*)(lhsVal.value)) * (*(bool*)(rhsVal.value)));
      val.type = BOOL;
    }
  }
}

void doSubtraction(TYPE_INFO& val, Expression* lhs, Expression* rhs)
{
  TYPE_INFO lhsVal = lhs->eval(), rhsVal = rhs->eval();
  if (lhsVal.type == INT)
  {
    if (rhsVal.type == INT)
    {
      val.value = new int((*(int*)(lhsVal.value)) - (*(int*)(rhsVal.value)));
      val.type = INT;
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new float((*(int*)(lhsVal.value)) - (*(float*)(rhsVal.value)));
      val.type = FLOAT;
    }
    else
    {
      val.value = new int((*(int*)(lhsVal.value)) - (*(bool*)(rhsVal.value)));
      val.type = INT;
    }
  }
  else if (lhsVal.type == FLOAT)
  {
    val.type = FLOAT;
    if (rhsVal.type == INT)
    {
      val.value = new float((*(float*)(lhsVal.value)) - (*(int*)(rhsVal.value)));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new float((*(float*)(lhsVal.value)) - (*(float*)(rhsVal.value)));
    }
    else
    {
      val.value = new float((*(float*)(lhsVal.value)) - (*(bool*)(rhsVal.value)));
    }
  }
  else
  {
    if (rhsVal.type == INT)
    {
      val.value = new int((*(bool*)(lhsVal.value)) - (*(int*)(rhsVal.value)));
      val.type = INT;
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new float((*(bool*)(lhsVal.value)) - (*(float*)(rhsVal.value)));
      val.type = FLOAT;
    }
    else
    {
      val.value = new int((*(bool*)(lhsVal.value)) - (*(bool*)(rhsVal.value)));
      val.type = INT;
    }
  }
}

void doDivision(TYPE_INFO& val, Expression* lhs, Expression* rhs)
{
  TYPE_INFO lhsVal = lhs->eval(), rhsVal = rhs->eval();
  if (lhsVal.type == INT)
  {
    if (rhsVal.type == INT)
    {
      if ((*(int*)(rhsVal.value)) == 0)
        yyerror("Attempted division by zero");
      val.value = new int((*(int*)(lhsVal.value)) / (*(int*)(rhsVal.value)));
      val.type = INT;
    }
    else if (rhsVal.type == FLOAT)
    {
      if ((*(float*)(rhsVal.value)) == 0)
        yyerror("Attempted division by zero");
      val.value = new float((*(int*)(lhsVal.value)) / (*(float*)(rhsVal.value)));
      val.type = FLOAT;
    }
    else
    {
      if ((*(bool*)(rhsVal.value)) == 0)
        yyerror("Attempted division by zero");
      val.value = new int((*(int*)(lhsVal.value)) / (*(bool*)(rhsVal.value)));
      val.type = INT;
    }
  }
  else if (lhsVal.type == FLOAT)
  {
    if (rhsVal.type == INT)
    {
      if ((*(int*)(rhsVal.value)) == 0)
        yyerror("Attempted division by zero");
      val.value = new float((*(float*)(lhsVal.value)) / (*(int*)(rhsVal.value)));
      val.type = FLOAT;
    }
    else if (rhsVal.type == FLOAT)
    {
      if ((*(float*)(rhsVal.value)) == 0)
        yyerror("Attempted division by zero");
      val.value = new float((*(float*)(lhsVal.value)) / (*(float*)(rhsVal.value)));
      val.type = FLOAT;
    }
    else
    {
      if ((*(bool*)(rhsVal.value)) == 0)
        yyerror("Attempted division by zero");
      val.value = new float((*(float*)(lhsVal.value)) / (*(bool*)(rhsVal.value)));
      val.type = FLOAT;
    }
  }
  else
  {
    if (rhsVal.type == INT)
    {
      if ((*(int*)(rhsVal.value)) == 0)
        yyerror("Attempted division by zero");
      val.value = new int((*(bool*)(lhsVal.value)) / (*(int*)(rhsVal.value)));
      val.type = INT;
    }
    else if (rhsVal.type == FLOAT)
    {
      if ((*(float*)(rhsVal.value)) == 0)
        yyerror("Attempted division by zero");
      val.value = new float((*(bool*)(lhsVal.value)) / (*(float*)(rhsVal.value)));
      val.type = FLOAT;
    }
    else
    {
      if ((*(bool*)(rhsVal.value)) == 0)
        yyerror("Attempted division by zero");
      val.value = new bool((*(bool*)(lhsVal.value)) / (*(bool*)(rhsVal.value)));
      val.type = BOOL;
    }
  }
}

void doModulous(TYPE_INFO& val, Expression* rhs, Expression* lhs)
{
  TYPE_INFO lhsVal = lhs->eval(), rhsVal = rhs->eval();
  if (rhsVal.type == INT)
  {
    if (lhsVal.type == INT)
    {
      if ((*(int*)(lhsVal.value)) == 0)
        yyerror("Attempted division by zero");
      val.value = new int((*(int*)(rhsVal.value)) % (*(int*)(lhsVal.value)));
      val.type = INT;
    }
    else if (lhsVal.type == FLOAT)
    {
      if ((*(float*)(lhsVal.value)) == 0)
        yyerror("Attempted division by zero");
      val.value = new float(fmod((*(int*)(rhsVal.value)), (*(float*)(lhsVal.value))));
      val.type = FLOAT;
    }
    else
    {
      if ((*(bool*)(lhsVal.value)) == 0)
        yyerror("Attempted division by zero");
      val.value = new int((*(int*)(rhsVal.value)) % (*(bool*)(lhsVal.value)));
      val.type = INT;
    }
  }
  else if (rhsVal.type == FLOAT)
  {
    if (lhsVal.type == INT)
    {
      if ((*(int*)(lhsVal.value)) == 0)
        yyerror("Attempted division by zero");
      val.value = new float(fmod((*(float*)(rhsVal.value)), (*(int*)(lhsVal.value))));
      val.type = FLOAT;
    }
    else if (lhsVal.type == FLOAT)
    {
      if ((*(float*)(lhsVal.value)) == 0)
        yyerror("Attempted division by zero");
      val.value = new float(fmod((*(float*)(rhsVal.value)), (*(float*)(lhsVal.value))));
      val.type = FLOAT;
    }
    else
    {
      if ((*(bool*)(lhsVal.value)) == 0)
        yyerror("Attempted division by zero");
      val.value = new float(fmod((*(float*)(rhsVal.value)), (*(bool*)(lhsVal.value))));
      val.type = FLOAT;
    }
  }
  else
  {
    if (lhsVal.type == INT)
    {
      if ((*(int*)(lhsVal.value)) == 0)
        yyerror("Attempted division by zero");
      val.value = new bool((*(bool*)(rhsVal.value)) % (*(int*)(lhsVal.value)));
      val.type = BOOL;
    }
    else if (lhsVal.type == FLOAT)
    {
      if ((*(float*)(lhsVal.value)) == 0)
        yyerror("Attempted division by zero");
      val.value = new bool(fmod((*(bool*)(rhsVal.value)), (*(float*)(lhsVal.value))));
      val.type = BOOL;
    }
    else
    {
      if ((*(bool*)(lhsVal.value)) == 0)
        yyerror("Attempted division by zero");
      val.value = new bool((*(bool*)(rhsVal.value)) % (*(bool*)(lhsVal.value)));
      val.type = BOOL;
    }
  }
}

void doPow(TYPE_INFO& val, Expression* lhs, Expression* rhs)
{
  TYPE_INFO lhsVal = lhs->eval(), rhsVal = rhs->eval();
  if (lhsVal.type == INT)
  {
    if (rhsVal.type == INT)
    {
      val.value = new int(pow((*(int*)(lhsVal.value)), (*(int*)(rhsVal.value))));
      val.type = INT;
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new float(pow((*(int*)(lhsVal.value)), (*(float*)(rhsVal.value))));
      val.type = FLOAT;
    }
    else
    {
      val.value = new int(pow((*(int*)(lhsVal.value)), (*(bool*)(rhsVal.value))));
      val.type = INT;
    }
  }
  else if (lhsVal.type == FLOAT)
  {
    if (rhsVal.type == INT)
    {
      val.value = new float(pow((*(float*)(lhsVal.value)), (*(int*)(rhsVal.value))));
      val.type = FLOAT;
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new float(pow((*(float*)(lhsVal.value)), (*(float*)(rhsVal.value))));
      val.type = FLOAT;
    }
    else
    {
      val.value = new float(pow((*(float*)(lhsVal.value)), (*(bool*)(rhsVal.value))));
      val.type = FLOAT;
    }
  }
  else
  {
    val.type = BOOL;
    if (rhsVal.type == INT)
    {
      val.value = new int(pow((*(bool*)(lhsVal.value)), (*(int*)(rhsVal.value))));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new float(pow((*(bool*)(lhsVal.value)), (*(float*)(rhsVal.value))));
    }
    else
    {
      val.value = new bool(pow((*(bool*)(lhsVal.value)), (*(bool*)(rhsVal.value))));
    }
  }
}

void doOr(TYPE_INFO& val, Expression* lhs, Expression* rhs)
{
  TYPE_INFO lhsVal = lhs->eval(), rhsVal = rhs->eval();
  if (lhsVal.type == INT)
  {
    if (rhsVal.type == INT)
    {
      val.type = INT;
      val.value = new int(max((*(int*)(lhsVal.value)), (*(int*)(rhsVal.value))));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.type = FLOAT;
      val.value = new float(max((*(int*)(lhsVal.value)), (*(float*)(rhsVal.value))));
    }
    else
    {
      val.type = INT;
      val.value = new int(max((*(int*)(lhsVal.value)), (*(bool*)(rhsVal.value))));
    }
  }
  else if (lhsVal.type == FLOAT)
  {
    val.type = FLOAT;
    if (rhsVal.type == INT)
    {
      val.value = new float(max((*(float*)(lhsVal.value)), (*(int*)(rhsVal.value))));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new float(max((*(float*)(lhsVal.value)), (*(float*)(rhsVal.value))));
    }
    else
    {
      val.value = new float(max((*(float*)(lhsVal.value)), (*(bool*)(rhsVal.value))));
    }
  }
  else
  {
    if (rhsVal.type == INT)
    {
      val.type = INT;
      val.value = new bool(max((*(bool*)(lhsVal.value)), (*(int*)(rhsVal.value))));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.type = FLOAT;
      val.value = new bool(max((*(bool*)(lhsVal.value)), (*(float*)(rhsVal.value))));
    }
    else
    {
      val.type = BOOL;
      val.value = new bool(max((*(bool*)(lhsVal.value)), (*(bool*)(rhsVal.value))));
    }
  }
}

void doAnd(TYPE_INFO& val, Expression* lhs, Expression* rhs)
{
  TYPE_INFO lhsVal = lhs->eval(), rhsVal = rhs->eval();
  if (lhsVal.type == INT)
  {
    if (rhsVal.type == INT)
    {
      val.type = INT;
      val.value = new int(min((*(int*)(lhsVal.value)), (*(int*)(rhsVal.value))));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.type = FLOAT;
      val.value = new float(min((*(int*)(lhsVal.value)), (*(float*)(rhsVal.value))));
    }
    else
    {
      val.type = INT;
      val.value = new int(min((*(int*)(lhsVal.value)), (*(bool*)(rhsVal.value))));
    }
  }
  else if (lhsVal.type == FLOAT)
  {
    val.type = FLOAT;
    if (rhsVal.type == INT)
    {
      val.value = new float(min((*(float*)(lhsVal.value)), (*(int*)(rhsVal.value))));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new float(min((*(float*)(lhsVal.value)), (*(float*)(rhsVal.value))));
    }
    else
    {
      val.value = new float(min((*(float*)(lhsVal.value)), (*(bool*)(rhsVal.value))));
    }
  }
  else
  {
    if (rhsVal.type == INT)
    {
      val.type = INT;
      val.value = new int(min((*(bool*)(lhsVal.value)), (*(int*)(rhsVal.value))));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.type = FLOAT;
      val.value = new float(min((*(bool*)(lhsVal.value)), (*(float*)(rhsVal.value))));
    }
    else
    {
      val.type = BOOL;
      val.value = new bool(min((*(bool*)(lhsVal.value)), (*(bool*)(rhsVal.value))));
    }
  }
}

void doNegate(string name)
{
  TYPE_INFO& temp = findEntryInAnyScopeTYPE(name);

  if (temp.type == INT)
  {
    temp.value = new int(-(*(int*)(temp.value)));
  }
  else if (temp.type == FLOAT)
  {
    temp.value = new float(-(*(float*)(temp.value)));
  }
  else if (temp.type == BOOL)
  {
    temp.value = new int(-(*(bool*)(temp.value)));
    temp.type = INT;
  }
}

void doNegate(TYPE_INFO& temp)
{
  if (temp.type == INT)
  {
    temp.value = new int(-(*(int*)(temp.value)));
  }
  else if (temp.type == FLOAT)
  {
    temp.value = new float(-(*(float*)(temp.value)));
  }
  else if (temp.type == BOOL)
  {
    temp.value = new int(-(*(bool*)(temp.value)));
    temp.type = INT;
  }
}

void doLT(TYPE_INFO& val, Expression* lhs, Expression* rhs)
{
  TYPE_INFO lhsVal = lhs->eval(), rhsVal = rhs->eval();
  val.type = BOOL;
  if (lhsVal.type == INT)
  {
    if (rhsVal.type == INT)
    {
      val.value = new bool(*(int*)(lhsVal.value) < *(int*)(rhsVal.value));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new bool(*(int*)(lhsVal.value) < *(float*)(rhsVal.value));
    }
    else
    {
      val.value = new bool(*(int*)(lhsVal.value) < *(bool*)(rhsVal.value));
    }
  }
  else if (lhsVal.type == FLOAT)
  {
    if (rhsVal.type == INT)
    {
      val.value = new bool(*(float*)(lhsVal.value) < *(int*)(rhsVal.value));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new bool(*(float*)(lhsVal.value) < *(float*)(rhsVal.value));
    }
    else
    {
      val.value = new bool(*(float*)(lhsVal.value) < *(bool*)(rhsVal.value));
    }
  }
  else
  {
    if (rhsVal.type == INT)
    {
      val.value = new bool(*(bool*)(lhsVal.value) < *(int*)(rhsVal.value));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new bool(*(bool*)(lhsVal.value) < *(float*)(rhsVal.value));
    }
    else
    {
      val.value = new bool(*(bool*)(lhsVal.value) < *(bool*)(rhsVal.value));
    }
  }
}

void doLE(TYPE_INFO& val, Expression* lhs, Expression* rhs)
{
  TYPE_INFO lhsVal = lhs->eval(), rhsVal = rhs->eval();
  val.type = BOOL;
  if (lhsVal.type == INT)
  {
    if (rhsVal.type == INT)
    {
      val.value = new bool(*(int*)(lhsVal.value) <= *(int*)(rhsVal.value));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new bool(*(int*)(lhsVal.value) <= *(float*)(rhsVal.value));
    }
    else
    {
      val.value = new bool(*(int*)(lhsVal.value) <= *(bool*)(rhsVal.value));
    }
  }
  else if (lhsVal.type == FLOAT)
  {
    if (rhsVal.type == INT)
    {
      val.value = new bool(*(float*)(lhsVal.value) <= *(int*)(rhsVal.value));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new bool(*(float*)(lhsVal.value) <= *(float*)(rhsVal.value));
    }
    else
    {
      val.value = new bool(*(float*)(lhsVal.value) <= *(bool*)(rhsVal.value));
    }
  }
  else
  {
    if (rhsVal.type == INT)
    {
      val.value = new bool(*(bool*)(lhsVal.value) <= *(int*)(rhsVal.value));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new bool(*(bool*)(lhsVal.value) <= *(float*)(rhsVal.value));
    }
    else
    {
      val.value = new bool(*(bool*)(lhsVal.value) <= *(bool*)(rhsVal.value));
    }
  }
}

void doGT(TYPE_INFO& val, Expression* lhs, Expression* rhs)
{
  TYPE_INFO lhsVal = lhs->eval(), rhsVal = rhs->eval();
  val.type = BOOL;
  if (lhsVal.type == INT)
  {
    if (rhsVal.type == INT)
    {
      val.value = new bool(*(int*)(lhsVal.value) > *(int*)(rhsVal.value));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new bool(*(int*)(lhsVal.value) > *(float*)(rhsVal.value));
    }
    else
    {
      val.value = new bool(*(int*)(lhsVal.value) > *(bool*)(rhsVal.value));
    }
  }
  else if (lhsVal.type == FLOAT)
  {
    if (rhsVal.type == INT)
    {
      val.value = new bool(*(float*)(lhsVal.value) > *(int*)(rhsVal.value));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new bool(*(float*)(lhsVal.value) > *(float*)(rhsVal.value));
    }
    else
    {
      val.value = new bool(*(float*)(lhsVal.value) > *(bool*)(rhsVal.value));
    }
  }
  else
  {
    if (rhsVal.type == INT)
    {
      val.value = new bool(*(bool*)(lhsVal.value) > *(int*)(rhsVal.value));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new bool(*(bool*)(lhsVal.value) > *(float*)(rhsVal.value));
    }
    else
    {
      val.value = new bool(*(bool*)(lhsVal.value) > *(bool*)(rhsVal.value));
    }
  }
}

void doGE(TYPE_INFO& val, Expression* lhs, Expression* rhs)
{
  TYPE_INFO lhsVal = lhs->eval(), rhsVal = rhs->eval();
  val.type = BOOL;
  if (lhsVal.type == INT)
  {
    if (rhsVal.type == INT)
    {
      val.value = new bool(*(int*)(lhsVal.value) >= *(int*)(rhsVal.value));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new bool(*(int*)(lhsVal.value) >= *(float*)(rhsVal.value));
    }
    else
    {
      val.value = new bool(*(int*)(lhsVal.value) >= *(bool*)(rhsVal.value));
    }
  }
  else if (lhsVal.type == FLOAT)
  {
    if (rhsVal.type == INT)
    {
      val.value = new bool(*(float*)(lhsVal.value) >= *(int*)(rhsVal.value));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new bool(*(float*)(lhsVal.value) >= *(float*)(rhsVal.value));
    }
    else
    {
      val.value = new bool(*(float*)(lhsVal.value) >= *(bool*)(rhsVal.value));
    }
  }
  else
  {
    if (rhsVal.type == INT)
    {
      val.value = new bool(*(bool*)(lhsVal.value) >= *(int*)(rhsVal.value));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new bool(*(bool*)(lhsVal.value) >= *(float*)(rhsVal.value));
    }
    else
    {
      val.value = new bool(*(bool*)(lhsVal.value) >= *(bool*)(rhsVal.value));
    }
  }
}

void doNE(TYPE_INFO& val, Expression* lhs, Expression* rhs)
{
  TYPE_INFO lhsVal = lhs->eval(), rhsVal = rhs->eval();
  val.type = BOOL;
  if (lhsVal.type == INT)
  {
    if (rhsVal.type == INT)
    {
      val.value = new bool(*(int*)(lhsVal.value) != *(int*)(rhsVal.value));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new bool(*(int*)(lhsVal.value) != *(float*)(rhsVal.value));
    }
    else
    {
      val.value = new bool(*(int*)(lhsVal.value) != *(bool*)(rhsVal.value));
    }
  }
  else if (lhsVal.type == FLOAT)
  {
    if (rhsVal.type == INT)
    {
      val.value = new bool(*(float*)(lhsVal.value) != *(int*)(rhsVal.value));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new bool(*(float*)(lhsVal.value) != *(float*)(rhsVal.value));
    }
    else
    {
      val.value = new bool(*(float*)(lhsVal.value) != *(bool*)(rhsVal.value));
    }
  }
  else if (lhsVal.type == BOOL)
  {
    if (rhsVal.type == INT)
    {
      val.value = new bool(*(bool*)(lhsVal.value) != *(int*)(rhsVal.value));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new bool(*(bool*)(lhsVal.value) != *(float*)(rhsVal.value));
    }
    else
    {
      val.value = new bool(*(bool*)(lhsVal.value) != *(bool*)(rhsVal.value));
    }
  }
  else
  {
    val.value = new bool(strcmp((*(string*)(lhsVal.value)).c_str(), (*(string*)(rhsVal.value)).c_str()));
  }
}

void doEQ(TYPE_INFO& val, Expression* lhs, Expression* rhs)
{
  TYPE_INFO lhsVal = lhs->eval(), rhsVal = rhs->eval();
  val.type = BOOL;
  if (lhsVal.type == INT)
  {
    if (rhsVal.type == INT)
    {
      val.value = new bool(*(int*)(lhsVal.value) == *(int*)(rhsVal.value));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new bool(*(int*)(lhsVal.value) == *(float*)(rhsVal.value));
    }
    else
    {
      val.value = new bool(*(int*)(lhsVal.value) == *(bool*)(rhsVal.value));
    }
  }
  else if (lhsVal.type == FLOAT)
  {
    if (rhsVal.type == INT)
    {
      val.value = new bool(*(float*)(lhsVal.value) == *(int*)(rhsVal.value));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new bool(*(float*)(lhsVal.value) == *(float*)(rhsVal.value));
    }
    else
    {
      val.value = new bool(*(float*)(lhsVal.value) == *(bool*)(rhsVal.value));
    }
  }
  else if (lhsVal.type == BOOL)
  {
    if (rhsVal.type == INT)
    {
      val.value = new bool(*(bool*)(lhsVal.value) == *(int*)(rhsVal.value));
    }
    else if (rhsVal.type == FLOAT)
    {
      val.value = new bool(*(bool*)(lhsVal.value) == *(float*)(rhsVal.value));
    }
    else
    {
      val.value = new bool(*(bool*)(lhsVal.value) == *(bool*)(rhsVal.value));
    }
  }
  else
  {
    val.value = new bool((*(string*)(lhsVal.value)) == (*(string*)(rhsVal.value)));
  }
}

int main(int argc, char* argv[])
{
  beginScope();
  if (argc == 1)
    printPrompt = true;
  else if (argc == 2)
  {
    printPrompt = false;
    yyin = fopen(argv[1], "r");
  }
  else
  {
    cout << "Usage: ./parser fileName" << endl;
    exit(1);
  }
  if (printPrompt)
    cout << ">>> ";
  do
  {
	  yyparse();
  } while (!feof(yyin));

  return(0);
}