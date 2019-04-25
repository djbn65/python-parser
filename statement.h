#ifndef STATEMENT_H
#define STATEMENT_H

#include <iostream>
#include <list>

struct TYPE_INFO;

class Statement
{
    public:
        virtual void eval() const = 0;
};

class StatementList
{
    public:
        void eval() const {
            for (auto stmt : stmtList)
                stmt->eval();
        }
        void add(Statement* stmt) {
            stmtList.push_back(stmt);
        }
    private:
        list<Statement*> stmtList;
};

class Assignment : public Statement
{
    public:
        Assignment(string name, TYPE_INFO value) : identName(name), expression(value) {}
        virtual void eval() const {
            valueAssignment(findEntryInAnyScopeTYPE(identName).value, expression.value, expression.type);
        }
    private:
        string identName;
        TYPE_INFO expression;
};

class Print : public Statement
{
    public:
        Print(TYPE_INFO value) : expression(value) {}
        virtual void eval() const {
            outputValue(expression.value, expression.type);
        }
    private:
        TYPE_INFO expression;
};

class IfElseStatement : public Statement
{
    public:
        IfElseStatement(bool branch, StatementList trueList, StatementList falseList) : condition(branch), ifTrue(trueList), ifFalse(falseList) {}
        virtual void eval() const {
            if (condition)
                ifTrue.eval();
            else
                ifFalse.eval();
        }
    private:
        bool condition;
        StatementList ifTrue;
        StatementList ifFalse;
};

#endif