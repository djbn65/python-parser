#ifndef SYMBOL_TABLE_ENTRY_H
#define SYMBOL_TABLE_ENTRY_H

#include <string>
#include <vector>
using namespace std;

#define INDEXTYPE -2
#define UNDEF -1
#define NOT_APPLICABLE -1
#define NULLTYPE 0
#define INT 1
#define STR 2
#define BOOL 3
#define FLOAT 4
#define LIST 5
#define ARITH_OPER 6
#define LOGIC_OPER 7
#define LT 8
#define GT 9
#define EQ 10
#define LE 11
#define GE 12
#define NE 13
#define ADD 14
#define SUB 15
#define DIV 16
#define MULT 17
#define POW 18
#define MOD 19
#define OR 20
#define AND 21
#define FUNCTION 22

struct TYPE_INFO
{
  int type;       //one of the above type codes
  int numParams;  //numParams and returnType only applicable if type == FUNCTION
  int returnType;
  int operand;
  bool isFuncParam;
  void* value;
};

class SYMBOL_TABLE_ENTRY
{
private:
  // Member variables
  string name;
  TYPE_INFO typeCode;

public:
  // Constructors
  SYMBOL_TABLE_ENTRY( ) { 
    name = "";
    typeCode.type = UNDEF; 
    typeCode.numParams = NOT_APPLICABLE;
    typeCode.returnType = NOT_APPLICABLE;
  }

  SYMBOL_TABLE_ENTRY(const string theName, const TYPE_INFO theType)
  {
    name = theName;
    typeCode = theType;
  }

  // Accessors
  string getName() const { return name; }
  TYPE_INFO& getTypeCode() { return typeCode; }
};

#endif  // SYMBOL_TABLE_ENTRY_H
