%{
#include <cstdlib>
#include <string.h>
#include "../ast/ast.hpp"
#include "lexer.hpp"
#include "../parser/parser.hpp"

#define T_eof 0

int yycolumn = 1;

#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno; \
    yylloc.first_column = yycolumn; yylloc.last_column = yycolumn + yyleng - 1; \
    yycolumn += yyleng; \
    yylval.str = strdup(yytext);

// int lineno = 1;
int comment_depth = 0;

%}

L [a-zA-Z]
H [0-9a-fA-F]
D [0-9]
W [ \t\r]
ES \\([ntr0\\\'\"]|x{H}{H})
PR ({L}|{D}|[ ~!:@.#$%^&*\(\)_+\[\]\|\{\}])


%option noyywrap
%option nounput
%option yylineno

%x COMMENT

%%

"and"     { return T_and; }
"array"   { return T_array; }
"begin"   { return T_begin; }
"bool"    { return T_bool; }
"char"    { return T_char; }
"delete"  { return T_delete; }
"dim"     { return T_dim; }
"do"      { return T_do; }
"done"    { return T_done; }
"downto"  { return T_downto; }
"else"    { return T_else; }
"end"     { return T_end; }
"false"   { return T_false; }
"float"   { return T_float; }
"for"     { return T_for; }
"if"      { return T_if; }
"in"      { return T_in; }
"int"     { return T_int; }
"let"     { return T_let; }
"match"   { return T_match; }
"mod"     { return T_mod; }
"mutable" { return T_mutable; }
"new"     { return T_new; }
"not"     { return T_not; }
"of"      { return T_of; }
"rec"     { return T_rec; }
"ref"     { return T_ref; }
"then"    { return T_then; }
"to"      { return T_to; }
"true"    { return T_true; }
"type"    { return T_type; }
"unit"    { return T_unit; }
"while"   { return T_while; }
"with"    { return T_with; }


"->"      { return T_op_arrow; }
"+."      { return T_op_fadd; }
"-."      { return T_op_fsub; }
"*."      { return T_op_fmul; }
"/."      { return T_op_fdiv; }
"**"      { return T_op_fpow; }
"&&"      { return T_op_and; }
"||"      { return T_op_or; }
"<>"      { return T_op_struct_neq; }
"<="      { return T_op_leq; }
">="      { return T_op_geq; }
"=="      { return T_op_eq; }
"!="      { return T_op_phys_neq; }
":="      { return T_op_assign; }

[\=\|\+\-\*\/\!\;\<\>\(\)\[\]\,\:]  { return yytext[0]; }

{D}+                                { yylval.num = atoi(yytext); return T_const; }
{D}+\.{D}+([Ee][\+\-]?{D}+)?        { yylval.flt = atof(yytext); return T_const_float; }

\'({PR}|{ES})\'                     { yylval.chr = strdup(yytext); return T_const_char; }
\"(\\.|[^"\\\n])*\"                { yylval.str = strdup(yytext); return T_const_string; }
 
[a-z]({L}|{D}|_)*                   { yylval.ids = strdup(yytext); return T_id; }
[A-Z]({L}|{D}|_)*                   { yylval.constructor = strdup(yytext); return T_constructor; }


"--".*\n                            { yycolumn = 1; /* yylineno++; */ }

"(*"                                { BEGIN(COMMENT); comment_depth++; }
<COMMENT>"(*"                       { comment_depth++; }
<COMMENT>"*)"                       { if (!--comment_depth) BEGIN(INITIAL); }
<COMMENT>\n                         { yycolumn = 1; /* yylineno++; */ }
<COMMENT>[(|*]                      { /* do nothing */ }
<COMMENT>[^(*\n]+                   { /* do nothing */ }
<COMMENT><<EOF>>                    { fprintf(stderr, "Unfinished comment at EOF\n"); exit(1); }

\n                                  { yycolumn = 1; /* yylineno++; */ }
{W}                                 { /* do nothing */ }

<<EOF>>                             { return T_eof; }

.                                   { fprintf(stderr, "Illegal character '%c' in line %d\n", yytext[0], yylloc.first_line); exit(1); }

%%

// int main(){
//    int token;
//    do {
//       token = yylex();
//       printf("token=%d, lexeme='%s'\n", token, yytext);
//    } while (token != T_eof);
// }

void yyerror(const char *msg) {
  fprintf(stderr, "%s\n", msg);
  exit(1);
}