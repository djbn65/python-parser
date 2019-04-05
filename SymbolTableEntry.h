#ifndef SYMBOL_TABLE_ENTRY_H
#define SYMBOL_TABLE_ENTRY_H

#include <string>
using namespace std;

#define INDEXTYPE -2
#define UNDEF -1
#define NOT_APPLICABLE -1
#define NULLTYPE 0
#define INT 1
#define STR 2
#define INT_OR_STR 3
#define BOOL 4
#define INT_OR_BOOL 5
#define STR_OR_BOOL 6
#define FLOAT 7
#define INT_OR_FLOAT 8
#define STR_OR_FLOAT 9
#define INT_OR_STR_OR_FLOAT 10
#define BOOL_OR_FLOAT 11
#define LIST 12
#define INT_OR_LIST 13
#define STR_OR_LIST 14
#define BOOL_OR_LIST 16
#define ARITH_OPER 17
#define LOGIC_OPER 18
#define FLOAT_OR_LIST 19
#define FUNCTION 20
#define INT_OR_STR_OR_BOOL_OR_FLOAT 21
#define INT_OR_STR_OR_FLOAT_OR_LIST 22

typedef struct
{
  int type;       //one of the above type codes
  int numParams;  //numParams and returnType only applicable if type == FUNCTION
  int returnType;
  bool isFuncParam;
} TYPE_INFO;

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
