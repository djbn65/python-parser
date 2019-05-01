#ifndef STATEMENT_H
#define STATEMENT_H

#include <iostream>
#include <list>

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
        virtual Expression* neg() { return nullptr; }
};

class Var : public Expression
{
    public:
        Var(string var) : name(var) {}
        virtual TYPE_INFO eval() const {
            return findEntryInAnyScopeTYPE(name);
        }
        virtual Expression* neg() {
            doNegate(name);
            return this;
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
        virtual Expression* neg() {
            doNegate(expr);
            return this;
        }
    private:
        TYPE_INFO expr;
};

class IndVar : public Expression
{
    public:
        IndVar(string name, int indVal) : identName(name), ind(indVal) {}
        virtual TYPE_INFO eval() const {
            TYPE_INFO temp;
            int size = (*(vector<TYPE_INFO>*)(findEntryInAnyScopeTYPE(identName).value)).size();
            if (ind < 0)
            {
                temp.value = (*(vector<TYPE_INFO>*)(findEntryInAnyScopeTYPE(identName).value))[ind + size].value;
                temp.type = (*(vector<TYPE_INFO>*)(findEntryInAnyScopeTYPE(identName).value))[ind + size].type;
            }
            else
            {
                temp.value = (*(vector<TYPE_INFO>*)(findEntryInAnyScopeTYPE(identName).value))[ind].value;
                temp.type = (*(vector<TYPE_INFO>*)(findEntryInAnyScopeTYPE(identName).value))[ind].type;
            }
            return temp;
        }
    private:
        string identName;
        int ind;
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
        virtual int size() { return -1; }
        virtual Expression* getExpr() { return nullptr; }
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

        virtual int size() {
            return chainAssigns.size();
        }

        virtual Expression* getExpr() {
            if (index.type == INDEXTYPE)
                return new IndVar(identName, *(int*)(index.value));
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
        IfElseStatement(bool branch, StatementList trueList, StatementList falseList) : condition(branch), ifTrue(trueList), ifFalse(falseList) {}
        virtual void eval() const {
            if (condition && ifTrue.size())
                ifTrue.eval();
            else if (!condition && ifFalse.size())
                ifFalse.eval();
        }
    private:
        bool condition;
        StatementList ifTrue;
        StatementList ifFalse;
};

class ForLoop : public Statement
{
    public:
        ForLoop(string name, vector<TYPE_INFO> theList, StatementList theBody) : iterVar(name), iterable(theList), toLoop(theBody) {}
        virtual void eval() const {
            int size = iterable.size();
            toLoop.eval();
            for (int i = 1; i < size; i++)
            {
                findEntryInAnyScopeTYPE(iterVar).type = iterable[i].type;
                valueAssignment(findEntryInAnyScopeTYPE(iterVar).value, iterable[i].value, iterable[i].type);
                toLoop.eval();
            }
        }
    private:
        vector<TYPE_INFO> iterable;
        string iterVar;
        StatementList toLoop;
};

class ArithStatement : public Statement
{
    public:
        ArithStatement(Expression* value) : expression(value) {}
        virtual void eval() const {
            outputValue(expression->eval().value, expression->eval().type);
        }
    private:
        Expression* expression;
};

#endif