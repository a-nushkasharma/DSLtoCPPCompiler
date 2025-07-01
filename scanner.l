%{
#include <string>
#include <cstdlib>
#include <cstring>
using namespace std;
#include "ast.h"
#include "parser.hpp"
%}

%x COMMENT

%%

"contract"        { return CONTRACT; }
"uint"            { return UINT; }

[a-zA-Z_][a-zA-Z0-9_]*  { yylval.str = strdup(yytext); return IDENTIFIER; }

[0-9]+           { yylval.num = atoi(yytext); return NUMBER; }

"="              { return ASSIGN; }
"+"              { return PLUS; }
"-"              { return MINUS; }
"*"              { return MULT; }
"/"              { return DIV; }

"("              { return LPAREN; }
")"              { return RPAREN; }
"{"              { return LBRACE; }
"}"              { return RBRACE; }
";"              { return SEMICOLON; }

[ \t\r\n]+       ;     // Ignore whitespace
"//".*           ;     // Ignore single-line comments
.                { printf("Unknown character: %s\n", yytext); }

%%

int yywrap() {
    return 1;
}
// Code for a generic compiler with complete semantics for Solidity
/*
%{
#include <string>
#include <cstdlib>
#include <cstring>
#include "parser.hpp"
using namespace std;
%}

%%

"contract"        { return CONTRACT; }
"function"        { return FUNCTION; }
"public"          { return PUBLIC; }
"returns"         { return RETURNS; }

"uint"            { return UINT; }
"int"             { return INT; }
"bool"            { return BOOL; }
"address"         { return ADDRESS; }

"if"              { return IF; }
"else"            { return ELSE; }
"return"          { return RETURN; }

"true"            { yylval.num = 1; return BOOL_LITERAL; }
"false"           { yylval.num = 0; return BOOL_LITERAL; }

"0x"[a-fA-F0-9]+  { yylval.str = strdup(yytext); return ADDRESS_LITERAL; }

"=="              { return EQ; }
"!="              { return NEQ; }
">="              { return GE; }
"<="              { return LE; }
">"               { return GT; }
"<"               { return LT; }

"&&"              { return AND; }
"||"              { return OR; }
"!"               { return NOT; }

"+"               { return PLUS; }
"-"               { return MINUS; }
"*"               { return MULT; }
"/"               { return DIV; }
"%"               { return MOD; }

"="               { return ASSIGN; }

"("               { return LPAREN; }
")"               { return RPAREN; }
"{"               { return LBRACE; }
"}"               { return RBRACE; }
","               { return COMMA; }
";"               { return SEMICOLON; }

[0-9]+            { yylval.num = atoi(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return IDENTIFIER; }

[ \t\r\n]+        ;
"//".*            ;
.                 { printf("Unknown character: %s\n", yytext); }

%%

int yywrap() {
    return 1;
}
*/
