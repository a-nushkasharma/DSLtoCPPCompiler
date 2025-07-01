%{
#include <iostream>
#include <memory>
#include <string>
#include <vector>
#include "ast.h"

extern int yylex();
extern int yyparse();
extern FILE* yyin;
void yyerror(const char *s) { fprintf(stderr, "Parse error: %s\n", s); }

std::unique_ptr<Contract> contract;
%}

%union {
    int num;
    char* str;
    Expression* expr;
    VarDecl* vardecl;
    std::vector<VarDecl>* vardecl_list;
}

%token CONTRACT UINT
%token <str> IDENTIFIER
%token <num> NUMBER

%token LPAREN RPAREN LBRACE RBRACE SEMICOLON

%type <expr> Expression
%type <vardecl> Declaration
%type <vardecl_list> Declarations

%%

Program:
    CONTRACT IDENTIFIER LBRACE Declarations RBRACE
    {
        contract = std::make_unique<Contract>();
        contract->name = $2;
        contract->variables = std::move(*$4);
        delete $4;
    }
;

Declarations:
    Declarations Declaration {
        $1->push_back(std::move(*$2));
        delete $2;
        $$ = $1;
    }
    | Declaration {
        $$ = new std::vector<VarDecl>();
        $$->push_back(std::move(*$1));
        delete $1;
    }
;

Declaration:
    UINT IDENTIFIER ASSIGN Expression SEMICOLON {
        $$ = new VarDecl{$2, std::unique_ptr<Expression>($4)};
    }
;

Expression:
    Expression PLUS Expression {
        $$ = new BinaryExpr("+", std::unique_ptr<Expression>($1), std::unique_ptr<Expression>($3));
    }
    | Expression MINUS Expression {
        $$ = new BinaryExpr("-", std::unique_ptr<Expression>($1), std::unique_ptr<Expression>($3));
    }
    | Expression MULT Expression {
        $$ = new BinaryExpr("*", std::unique_ptr<Expression>($1), std::unique_ptr<Expression>($3));
    }
    | Expression DIV Expression {
        $$ = new BinaryExpr("/", std::unique_ptr<Expression>($1), std::unique_ptr<Expression>($3));
    }
    | LPAREN Expression RPAREN {
        $$ = $2;
    }
    | NUMBER {
        $$ = new NumberExpr($1);
    }
    | IDENTIFIER {
        $$ = new VariableExpr($1);
    }
;

%%

int main(int argc, char** argv) {
    if (argc < 2) {
        printf("Usage: %s <file.dsl>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Cannot open file");
        return 1;
    }

    yyparse();
    fclose(yyin);

    if (contract) {
        contract->generate(std::cout);  // Output C++ code
    }
// Code for Generic Compiler code-covers all the semantics of Solidity
/* %{
#include <iostream>
#include <memory>
#include <string>
#include <vector>
#include "ast.h"

extern int yylex();
extern int yyparse();
extern FILE* yyin;
void yyerror(const char *s) { fprintf(stderr, "Parse error: %s\n", s); }

std::unique_ptr<Contract> contract;
%}

%union {
    int num;
    char* str;
    Expression* expr;
    VarDecl* vardecl;
    Statement* stmt;
    Type type;
    std::vector<VarDecl>* vardecl_list;
    std::vector<Statement*>* stmt_list;
    Function* func;
    std::vector<Function>* func_list;
}

%token <str> IDENTIFIER
%token <num> NUMBER BOOL_LITERAL
%token <str> ADDRESS_LITERAL

%token CONTRACT FUNCTION PUBLIC RETURNS
%token UINT INT BOOL ADDRESS
%token IF ELSE RETURN

%token ASSIGN PLUS MINUS MULT DIV MOD
%token EQ NEQ GT LT GE LE
%token AND OR NOT

%token LPAREN RPAREN LBRACE RBRACE COMMA SEMICOLON

%type <expr> Expression
%type <vardecl> Param Declaration
%type <vardecl_list> ParamList
%type <type> Type ReturnType
%type <stmt> Statement
%type <stmt_list> StatementList Block
%type <func> FunctionDef
%type <func_list> FunctionList

%%

Program:
    CONTRACT IDENTIFIER LBRACE FunctionList RBRACE
    {
        contract = std::make_unique<Contract>();
        contract->name = $2;
        contract->functions = std::move(*$4);
        delete $4;
    }
;

FunctionList:
    FunctionList FunctionDef {
        $1->push_back(*$2);
        delete $2;
        $$ = $1;
    }
    | FunctionDef {
        $$ = new std::vector<Function>();
        $$->push_back(*$1);
        delete $1;
    }
;

FunctionDef:
    FUNCTION IDENTIFIER LPAREN ParamList RPAREN PUBLIC ReturnType Block {
        $$ = new Function();
        $$->name = $2;
        $$->params = std::move(*$4);
        $$->returnType = $7;
        $$->body.reserve($8->size());
        for (auto* stmt : *$8) $$->body.emplace_back(stmt);
        delete $4; delete $8;
    }
;

ParamList:
    ParamList COMMA Param {
        $1->push_back(*$3);
        delete $3;
        $$ = $1;
    }
    | Param {
        $$ = new std::vector<VarDecl>();
        $$->push_back(*$1);
        delete $1;
    }
    | /* empty */ { $$ = new std::vector<VarDecl>(); }
;

Param:
    Type IDENTIFIER {
        $$ = new VarDecl{$1, $2, nullptr};
    }
;

ReturnType:
    RETURNS LPAREN Type RPAREN { $$ = $3; }
;

Type:
    UINT    { $$ = Type::UINT; }
    | INT   { $$ = Type::INT; }
    | BOOL  { $$ = Type::BOOL; }
    | ADDRESS { $$ = Type::ADDRESS; }
;

Block:
    LBRACE StatementList RBRACE { $$ = $2; }
;

StatementList:
    StatementList Statement {
        $1->push_back($2);
        $$ = $1;
    }
    | /* empty */ {
        $$ = new std::vector<Statement*>();
    }
;

Statement:
    Declaration
    | IDENTIFIER ASSIGN Expression SEMICOLON {
        $$ = new ExprStmt(std::make_unique<BinaryExpr>("=", std::make_unique<VariableExpr>($1), std::unique_ptr<Expression>($3)));
    }
    | IF LPAREN Expression RPAREN Block {
        auto ifStmt = new ExprStmt(std::make_unique<UnaryExpr>("if", std::unique_ptr<Expression>($3)));
        for (auto* stmt : *$5) delete stmt;
        delete $5;
        $$ = ifStmt;
    }
    | IF LPAREN Expression RPAREN Block ELSE Block {
        auto ifStmt = new ExprStmt(std::make_unique<UnaryExpr>("if_else", std::unique_ptr<Expression>($3)));
        for (auto* stmt : *$5) delete stmt;
        for (auto* stmt : *$7) delete stmt;
        delete $5;
        delete $7;
        $$ = ifStmt;
    }
    | RETURN Expression SEMICOLON {
        $$ = new ReturnStmt(std::unique_ptr<Expression>($2));
    }
    | Expression SEMICOLON {
        $$ = new ExprStmt(std::unique_ptr<Expression>($1));
    }
;

Declaration:
    Type IDENTIFIER ASSIGN Expression SEMICOLON {
        $$ = new ExprStmt(std::make_unique<BinaryExpr>("decl_assign", std::make_unique<VariableExpr>($2), std::unique_ptr<Expression>($4)));
    }
    | Type IDENTIFIER SEMICOLON {
        $$ = new ExprStmt(std::make_unique<VariableExpr>($2)); // just declared
    }
;

Expression:
    Expression PLUS Expression  { $$ = new BinaryExpr("+", std::unique_ptr<Expression>($1), std::unique_ptr<Expression>($3)); }
    | Expression MINUS Expression { $$ = new BinaryExpr("-", std::unique_ptr<Expression>($1), std::unique_ptr<Expression>($3)); }
    | Expression MULT Expression { $$ = new BinaryExpr("*", std::unique_ptr<Expression>($1), std::unique_ptr<Expression>($3)); }
    | Expression DIV Expression  { $$ = new BinaryExpr("/", std::unique_ptr<Expression>($1), std::unique_ptr<Expression>($3)); }
    | Expression MOD Expression  { $$ = new BinaryExpr("%", std::unique_ptr<Expression>($1), std::unique_ptr<Expression>($3)); }

    | Expression EQ Expression   { $$ = new BinaryExpr("==", std::unique_ptr<Expression>($1), std::unique_ptr<Expression>($3)); }
    | Expression NEQ Expression  { $$ = new BinaryExpr("!=", std::unique_ptr<Expression>($1), std::unique_ptr<Expression>($3)); }
    | Expression GT Expression   { $$ = new BinaryExpr(">", std::unique_ptr<Expression>($1), std::unique_ptr<Expression>($3)); }
    | Expression LT Expression   { $$ = new BinaryExpr("<", std::unique_ptr<Expression>($1), std::unique_ptr<Expression>($3)); }
    | Expression GE Expression   { $$ = new BinaryExpr(">=", std::unique_ptr<Expression>($1), std::unique_ptr<Expression>($3)); }
    | Expression LE Expression   { $$ = new BinaryExpr("<=", std::unique_ptr<Expression>($1), std::unique_ptr<Expression>($3)); }

    | Expression AND Expression  { $$ = new BinaryExpr("&&", std::unique_ptr<Expression>($1), std::unique_ptr<Expression>($3)); }
    | Expression OR Expression   { $$ = new BinaryExpr("||", std::unique_ptr<Expression>($1), std::unique_ptr<Expression>($3)); }

    | NOT Expression             { $$ = new UnaryExpr("!", std::unique_ptr<Expression>($2)); }
    | MINUS Expression           { $$ = new UnaryExpr("-", std::unique_ptr<Expression>($2)); }

    | LPAREN Expression RPAREN   { $$ = $2; }
    | NUMBER                     { $$ = new NumberExpr($1); }
    | BOOL_LITERAL               { $$ = new BoolExpr($1); }
    | ADDRESS_LITERAL            { $$ = new AddressExpr($1); }
    | IDENTIFIER                 { $$ = new VariableExpr($1); }
;

%%

int main(int argc, char** argv) {
    if (argc < 2) {
        printf("Usage: %s <file.dsl>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Cannot open file");
        return 1;
    }

    yyparse();
    fclose(yyin);

    if (contract) {
        contract->generate(std::cout);  // Output C++ code
    }

    return 0;
}


    return 0;
}
*/
