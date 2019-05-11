#ifndef STATEMENT_H
#define STATEMENT_H

#include <iostream>
#include <list>
#include <cstring>

struct TYPE_INFO;

class Assignment;

class Expression
{
    public:
        virtual TYPE_INFO eval() const = 0;
        virtual void setLhs(Expression*) {}
        virtual void setRhs(Expression*) {}
        virtual Expression* getLhs() { return nullptr; }
        virtual Expression* getRhs() { return nullptr; }
        virtual bool evalBool() {
            TYPE_INFO temp = eval();
            if (temp.type == INT)
            {
                if (*(int*)(temp.value) != 0)
                    return true;
            }
            else if (temp.type == FLOAT)
            {
                if (abs(*(float*)(temp.value)) > 0.0000000000000000000000001)
                    return true;
            }
            else if (temp.type == BOOL)
            {
                if (*(bool*)(temp.value))
                    return true;
            }
            else if (temp.type == STR)
            {
                if (strlen((*(string*)(temp.value)).c_str()))
                    return true;
            }
            else if (temp.type == LIST)
            {
                if ((*(vector<TYPE_INFO>*)(temp.value)).size())
                    return true;
            }
            return false;
        }
        virtual string getName() {return "TEMP"; }
};

class Var : public Expression
{
    public:
        Var(string var) : name(var) {}
        virtual TYPE_INFO eval() const {
            return findEntryInAnyScopeTYPE(name);
        }
        virtual string getName() {
            return name;
        }
    private:
        string name;
};

class Const : public Expression
{
    public:
        Const(TYPE_INFO var) : expr(var) {}
        virtual TYPE_INFO eval() const {
            return expr;
        }
    private:
        TYPE_INFO expr;
};

class Input : public Expression
{
    public:
        Input() {
            TYPE_INFO temp;
            temp.type = STR;
            temp.value = new string("");
            out = new Const(temp);
        }
        Input(Expression* prompt) : out(prompt) {}
        virtual TYPE_INFO eval() const {
            TYPE_INFO outExpr = out->eval();
            if (outExpr.type == INT)
            {
                cout << *(int*)(outExpr.value);
            }
            else if (outExpr.type == FLOAT)
            {
                cout << *(float*)(outExpr.value);
            }
            else if (outExpr.type == STR)
            {
                cout << *(string*)(outExpr.value);
            }
            else if (outExpr.type == BOOL)
            {
                cout << *(bool*)(outExpr.value);
            }
            else if (outExpr.type == LIST)
            {
                printList(*(vector<TYPE_INFO>*)(outExpr.value));
            }
            TYPE_INFO temp;
            string input;
            getline(cin, input);
            temp.value = new string(input);
            temp.type = STR;
            return temp;
        }
    private:
        Expression* out;
};

class IndVar : public Expression
{
    public:
        IndVar(string name, TYPE_INFO indVal) : identName(name), ind(indVal) {}
        virtual TYPE_INFO eval() const {
            TYPE_INFO temp;
            int size = (*(vector<TYPE_INFO>*)(findEntryInAnyScopeTYPE(identName).value)).size();
            if ((*(int*)(ind.expr->eval().value)) < 0)
            {
                temp.value = (*(vector<TYPE_INFO>*)(findEntryInAnyScopeTYPE(identName).value))[(*(int*)(ind.expr->eval().value)) + size].value;
                temp.type = (*(vector<TYPE_INFO>*)(findEntryInAnyScopeTYPE(identName).value))[(*(int*)(ind.expr->eval().value)) + size].type;
            }
            else
            {
                temp.value = (*(vector<TYPE_INFO>*)(findEntryInAnyScopeTYPE(identName).value))[(*(int*)(ind.expr->eval().value))].value;
                temp.type = (*(vector<TYPE_INFO>*)(findEntryInAnyScopeTYPE(identName).value))[(*(int*)(ind.expr->eval().value))].type;
            }
            return temp;
        }
    private:
        string identName;
        TYPE_INFO ind;
};

class BinaryExpression : public Expression
{
    public:
        BinaryExpression(Expression* LHS, Expression* RHS) : lhs(LHS), rhs(RHS) {}
        virtual TYPE_INFO eval() const = 0;
        virtual Expression* getRhs() { return rhs; }
        virtual Expression* getLhs() { return lhs; }
        virtual void setRhs(Expression* temp) {}
        virtual void setLhs(Expression* temp) {}
    protected:
        Expression *lhs, *rhs;
};

class Addition : public BinaryExpression
{
    public:
        Addition(Expression* LHS, Expression* RHS) : BinaryExpression(LHS, RHS) {}
        virtual TYPE_INFO eval() const {
            
            TYPE_INFO temp;
            doAddition(temp, lhs, rhs);
            return temp;
        }
        virtual void setRhs(Expression* temp) { rhs = temp; }
        virtual void setLhs(Expression* temp) { lhs = temp; }
};

class Subtraction : public BinaryExpression
{
    public:
        Subtraction(Expression* LHS, Expression* RHS) : BinaryExpression(LHS, RHS) {}
        virtual TYPE_INFO eval() const {
            TYPE_INFO temp;
            doSubtraction(temp, lhs, rhs);
            return temp;
        }
        virtual void setRhs(Expression* temp) { rhs = temp; }
        virtual void setLhs(Expression* temp) { lhs = temp; }
};

class Multiplication : public BinaryExpression
{
    public:
        Multiplication(Expression* LHS, Expression* RHS) : BinaryExpression(LHS, RHS) {}
        virtual TYPE_INFO eval() const {
            TYPE_INFO temp;
            doMultiplication(temp, lhs, rhs);
            return temp;
        }
        virtual void setRhs(Expression* temp) { rhs = temp; }
        virtual void setLhs(Expression* temp) { lhs = temp; }
};

class Division : public BinaryExpression
{
    public:
        Division(Expression* LHS, Expression* RHS) : BinaryExpression(LHS, RHS) {}
        virtual TYPE_INFO eval() const {
            TYPE_INFO temp;
            doDivision(temp, lhs, rhs);
            return temp;
        }
        virtual void setRhs(Expression* temp) { rhs = temp; }
        virtual void setLhs(Expression* temp) { lhs = temp; }
};

class Modulous : public BinaryExpression
{
    public:
        Modulous(Expression* LHS, Expression* RHS) : BinaryExpression(LHS, RHS) {}
        virtual TYPE_INFO eval() const {
            TYPE_INFO temp;
            doModulous(temp, lhs, rhs);
            return temp;
        }
        virtual void setRhs(Expression* temp) { rhs = temp; }
        virtual void setLhs(Expression* temp) { lhs = temp; }
};

class Exponent : public BinaryExpression
{
    public:
        Exponent(Expression* LHS, Expression* RHS) : BinaryExpression(LHS, RHS) {}
        virtual TYPE_INFO eval() const {
            TYPE_INFO temp;
            doPow(temp, lhs, rhs);
            return temp;
        }
        virtual void setRhs(Expression* temp) { rhs = temp; }
        virtual void setLhs(Expression* temp) { lhs = temp; }
};

class Or : public BinaryExpression
{
    public:
        Or(Expression* LHS, Expression* RHS) : BinaryExpression(LHS, RHS) {}
        virtual TYPE_INFO eval() const {
            TYPE_INFO temp;
            doOr(temp, lhs, rhs);
            return temp;
        }
        virtual void setRhs(Expression* temp) { rhs = temp; }
        virtual void setLhs(Expression* temp) { lhs = temp; }
};

class And : public BinaryExpression
{
    public:
        And(Expression* LHS, Expression* RHS) : BinaryExpression(LHS, RHS) {}
        virtual TYPE_INFO eval() const {
            TYPE_INFO temp;
            doAnd(temp, lhs, rhs);
            return temp;
        }
        virtual void setRhs(Expression* temp) { rhs = temp; }
        virtual void setLhs(Expression* temp) { lhs = temp; }
};

class lessThan : public BinaryExpression
{
    public:
        lessThan(Expression* LHS, Expression* RHS) : BinaryExpression(LHS, RHS) {}
        virtual TYPE_INFO eval() const {
            TYPE_INFO temp;
            doLT(temp, lhs, rhs);
            return temp;
        }
        virtual void setRhs(Expression* temp) { rhs = temp; }
        virtual void setLhs(Expression* temp) { lhs = temp; }
};

class lessEq : public BinaryExpression
{
    public:
        lessEq(Expression* LHS, Expression* RHS) : BinaryExpression(LHS, RHS) {}
        virtual TYPE_INFO eval() const {
            TYPE_INFO temp;
            doLE(temp, lhs, rhs);
            return temp;
        }
        virtual void setRhs(Expression* temp) { rhs = temp; }
        virtual void setLhs(Expression* temp) { lhs = temp; }
};

class greaterThan : public BinaryExpression
{
    public:
        greaterThan(Expression* LHS, Expression* RHS) : BinaryExpression(LHS, RHS) {}
        virtual TYPE_INFO eval() const {
            TYPE_INFO temp;
            doGT(temp, lhs, rhs);
            return temp;
        }
        virtual void setRhs(Expression* temp) { rhs = temp; }
        virtual void setLhs(Expression* temp) { lhs = temp; }
};

class greaterEq : public BinaryExpression
{
    public:
        greaterEq(Expression* LHS, Expression* RHS) : BinaryExpression(LHS, RHS) {}
        virtual TYPE_INFO eval() const {
            TYPE_INFO temp;
            doGE(temp, lhs, rhs);
            return temp;
        }
        virtual void setRhs(Expression* temp) { rhs = temp; }
        virtual void setLhs(Expression* temp) { lhs = temp; }
};

class notEq : public BinaryExpression
{
    public:
        notEq(Expression* LHS, Expression* RHS) : BinaryExpression(LHS, RHS) {}
        virtual TYPE_INFO eval() const {
            TYPE_INFO temp;
            doNE(temp, lhs, rhs);
            return temp;
        }
        virtual void setRhs(Expression* temp) { rhs = temp; }
        virtual void setLhs(Expression* temp) { lhs = temp; }
};

class isEq : public BinaryExpression
{
    public:
        isEq(Expression* LHS, Expression* RHS) : BinaryExpression(LHS, RHS) {}
        virtual TYPE_INFO eval() const {
            TYPE_INFO temp;
            doEQ(temp, lhs, rhs);
            return temp;
        }
        virtual void setRhs(Expression* temp) { rhs = temp; }
        virtual void setLhs(Expression* temp) { lhs = temp; }
};

class Not : public Expression
{
    public:
        Not(Expression* RHS) : rhs(RHS) {}
        virtual TYPE_INFO eval() const {
            TYPE_INFO temp = rhs->eval();
            if (temp.type == INT)
            {
                temp.value = new bool(!(*(int*)(temp.value)));
                temp.type = BOOL;
            }
            else if (temp.type == FLOAT)
            {
                temp.value = new bool(!(*(float*)(temp.value)));
                temp.type = BOOL;
            }
            else
            {
                temp.value = new bool(!(*(bool*)(temp.value)));
                temp.type == BOOL;
            }
            return temp;
        }
    private:
        Expression* rhs;
};

class Neg : public Expression
{
    public:
        Neg(Expression* RHS) : rhs(RHS) {}
        virtual TYPE_INFO eval() const {
            TYPE_INFO temp = rhs->eval();
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
                if (*(bool*)(temp.value) == true)
                {
                    temp.value = new int(-(*(bool*)(temp.value)));
                    temp.type = INT;
                }
                else
                    temp.value = new bool(-(*(bool*)(temp.value)));
            }
            return temp;
        }
    private:
        Expression* rhs;
};

class Statement
{
    public:
        virtual void eval() const = 0;
        virtual void eval(void* value) const {}
        virtual void add(Statement* stmt) {}
        virtual void append(Statement* appendee) {}
        virtual list<Statement*>& getStmtList() {}
        virtual const list<Statement*>& getStmtList() const {}
        virtual string getName() {}
        virtual int size() const { return -1; }
        virtual Expression* getExpr() { return nullptr; }
        virtual const void call() const {}
};

class StatementList : public Statement
{
    public:
        void eval() const {
            for (auto stmt : stmtList)
                stmt->eval();
        }
        virtual void add(Statement* stmt) {
            stmtList.insert(stmtList.begin(), stmt);
        }
        int size() const {
            return stmtList.size();
        }
        virtual void append(Statement* appendee) {
            for (auto stmt : appendee->getStmtList())
                stmtList.push_back(stmt);
        }
        virtual list<Statement*>& getStmtList() {
            return stmtList;
        }

        virtual const list<Statement*>& getStmtList() const {
            return stmtList;
        }
    private:
        list<Statement*> stmtList;
};

class Assignment : public Statement
{
    public:
        Assignment(string name, int assignOp, TYPE_INFO indexVal, Expression* value) : identName(name), assign(assignOp), index(indexVal), expression(value) {}
        virtual void eval() const {
            for (auto stmt : chainAssigns.getStmtList())
                stmt->eval();
            if (index.type != INDEXTYPE)
            {
                if (ScopeStack.top().findEntry(identName).type == UNDEF)
                {
                    TYPE_INFO temp;
                    temp.type = UNDEF;
                    temp.numParams = NOT_APPLICABLE;
                    temp.returnType = NOT_APPLICABLE;
                    temp.isFuncParam = false;
                    ScopeStack.top().addEntry(SYMBOL_TABLE_ENTRY(identName, temp));
                }
            }
            TYPE_INFO temp = expression->eval();
            if (index.type == INDEXTYPE)
            {
                int size = (*(vector<TYPE_INFO>*)(findEntryInAnyScopeTYPE(identName).value)).size();
                if (*(int*)(index.value) < -size ||
                    *(int*)(index.value) >= size)
                    yyerror("Subscript out of bounds");
                if (temp.type == STR)
                {
                    if ((*(int*)(index.value)) < 0)
                    {
                    (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry(identName).value))[(*(int*)(index.value)) + size].value = new std::string(*(std::string*)(temp.value));
                    (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry(identName).value))[(*(int*)(index.value)) + size].type = temp.type;
                    }
                    else
                    {
                    (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry(identName).value))[(*(int*)(index.value))].value = new std::string(*(std::string*)(temp.value));
                    (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry(identName).value))[(*(int*)(index.value))].type = temp.type;
                    }
                }
                else if (temp.type == INT)
                {
                    if ((*(int*)(index.value)) < 0)
                    {
                    (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry(identName).value))[(*(int*)(index.value)) + size].value = new int(*(int*)(temp.value));
                    (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry(identName).value))[(*(int*)(index.value)) + size].type = temp.type;
                    }
                    else
                    {
                    (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry(identName).value))[(*(int*)(index.value))].value = new int(*(int*)(temp.value));
                    (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry(identName).value))[(*(int*)(index.value))].type = temp.type;
                    }
                }
                else if (temp.type == FLOAT)
                {
                    if ((*(int*)(index.value)) < 0)
                    {
                    (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry(identName).value))[(*(int*)(index.value)) + size].value = new float(*(float*)(temp.value));
                    (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry(identName).value))[(*(int*)(index.value)) + size].type = temp.type;
                    }
                    else
                    {
                    (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry(identName).value))[(*(int*)(index.value))].value = new float(*(float*)(temp.value));
                    (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry(identName).value))[(*(int*)(index.value))].type = temp.type;
                    }
                }
                else if (temp.type == BOOL)
                {
                    if ((*(int*)(index.value)) < 0)
                    {
                    (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry(identName).value))[(*(int*)(index.value)) + size].value = new bool(*(bool*)(temp.value));
                    (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry(identName).value))[(*(int*)(index.value)) + size].type = temp.type;
                    }
                    else
                    {
                    (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry(identName).value))[(*(int*)(index.value))].value = new bool(*(bool*)(temp.value));
                    (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry(identName).value))[(*(int*)(index.value))].type = temp.type;
                    }
                }
                else if (temp.type == LIST)
                {
                    if ((*(int*)(index.value)) < 0)
                    {
                    (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry(identName).value))[(*(int*)(index.value)) + size].value = new vector<TYPE_INFO>(*(vector<TYPE_INFO>*)(temp.value));
                    (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry(identName).value))[(*(int*)(index.value)) + size].type = temp.type;
                    }
                    else
                    {
                    (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry(identName).value))[(*(int*)(index.value))].value = new vector<TYPE_INFO>(*(vector<TYPE_INFO>*)(temp.value));
                    (*(vector<TYPE_INFO>*)(ScopeStack.top().findEntry(identName).value))[(*(int*)(index.value))].type = temp.type;
                    }
                }
            }
            else
            {
                ScopeStack.top().findEntry(identName).type = temp.type;
                ScopeStack.top().findEntry(identName).numParams = temp.numParams;
                ScopeStack.top().findEntry(identName).returnType = temp.returnType;
                ScopeStack.top().findEntry(identName).isFuncParam = temp.isFuncParam;
                if (temp.type == STR)
                {
                    ScopeStack.top().findEntry(identName).value = new std::string(*(std::string*)(temp.value));
                }
                else if (temp.type == INT)
                {
                    ScopeStack.top().findEntry(identName).value = new int(*(int*)(temp.value));
                }
                else if (temp.type == FLOAT)
                {
                    ScopeStack.top().findEntry(identName).value = new float(*(float*)(temp.value));
                }
                else if (temp.type == BOOL)
                {
                    ScopeStack.top().findEntry(identName).value = new bool(*(bool*)(temp.value));
                }
                else if (temp.type == LIST)
                {
                    ScopeStack.top().findEntry(identName).value = new vector<TYPE_INFO>(*(vector<TYPE_INFO>*)(temp.value));
                }
            }
        }

        virtual void add(Statement* stmt) {
            chainAssigns.add(stmt);
        }

        virtual void append(Statement* appendee) {
            Assignment temp = *dynamic_cast<Assignment*>(appendee);
            for (auto stmt : appendee->getStmtList())
                chainAssigns.add(stmt);
        }

        virtual list<Statement*>& getStmtList() {
            return chainAssigns.getStmtList();
        }

        virtual const list<Statement*>& getStmtList() const {
            return chainAssigns.getStmtList();
        }

        virtual string getName() {
            return identName;
        }

        virtual int size() const {
            return chainAssigns.size();
        }

        virtual Expression* getExpr() {
            if (index.type == INDEXTYPE)
                return new IndVar(identName, index);
            else
                return new Var(identName);
        }
    private:
        string identName;
        int assign;
        TYPE_INFO index;
        Expression* expression;
        StatementList chainAssigns;
};

class Print : public Statement
{
    public:
        Print(Statement* value) : expression(value) {}
        virtual void eval() const {
            expression->eval();
        }
    private:
        Statement* expression;
};

class IfElseStatement : public Statement
{
    public:
        IfElseStatement(Expression* branch, StatementList trueList, StatementList falseList) : condition(branch), ifTrue(trueList), ifFalse(falseList) {}
        virtual void eval() const {
            if (condition->evalBool() && ifTrue.size())
                ifTrue.eval();
            else if (!(condition->evalBool()) && ifFalse.size())
                ifFalse.eval();
        }
    private:
        Expression* condition;
        StatementList ifTrue;
        StatementList ifFalse;
};

class WhileLoop : public Statement
{
    public:
        WhileLoop(Expression* cond, StatementList stmts) : condition(cond), body(stmts) {}
        virtual void eval() const {
            while (condition->evalBool())
                body.eval();
        }
    private:
        Expression* condition;
        StatementList body;
};

class ArithStatement : public Statement
{
    public:
        ArithStatement(Expression* value) : expression(value) {}
        virtual void eval() const {
            outputValue(expression->eval().value, expression->eval().type);
        }
        virtual int size() const {
            TYPE_INFO temp = expression->eval();
            if (temp.type == LIST)
                return (*(vector<TYPE_INFO>*)(temp.value)).size();
            else
                return -1;
        }
        virtual TYPE_INFO evaluate() const {
            return expression->eval();
        }
    private:
        Expression* expression;
};

class ForLoop : public Statement
{
    public:
        ForLoop(string name, ArithStatement theList, StatementList theBody) : iterVar(name), iterable(theList), toLoop(theBody) {}
        virtual void eval() const {
            const int size = iterable.size();
            for (int i = 0; i < size; i++)
            {
                findEntryInAnyScopeTYPE(iterVar).type = (*(vector<TYPE_INFO>*)(iterable.evaluate().value))[i].type;
                valueAssignment(findEntryInAnyScopeTYPE(iterVar).value, (*(vector<TYPE_INFO>*)(iterable.evaluate().value))[i].value, (*(vector<TYPE_INFO>*)(iterable.evaluate().value))[i].type);
                toLoop.eval();
            }
        }
    private:
        ArithStatement iterable;
        string iterVar;
        StatementList toLoop;
};

class FunctionDef : public Statement
{
    public:
        FunctionDef(string name, vector<string> names, StatementList stmts) : funcName(name), params(names), body(stmts) {}
        virtual void eval() const {
            findEntryInAnyScopeTYPE(funcName).stmt = new FunctionDef(*this);
        }
        virtual const void call() const {
            body.eval();
            for (int i = 0; i < params.size(); i++)
                ScopeStack.top().erase(params[i]);
        }
        virtual void setParams(vector<TYPE_INFO> x) {
            for (int i = 0; i < params.size(); i++)
                ScopeStack.top().addEntry(SYMBOL_TABLE_ENTRY(params[i], x[i]));
        }
    private:
        string funcName;
        vector<string> params;
        StatementList body;
};

class FunctionCall : public Statement
{
    public:
        FunctionCall(string name) : funcName(name) {}
        virtual void eval() const {
            findEntryInAnyScopeTYPE(funcName).stmt->call();
        }
    private:
        string funcName;
};

#endif