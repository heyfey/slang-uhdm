// § incDecMemberPathIsLvalue124
typedef struct { int a; int b; } s_t; typedef struct { s_t in; int c; } o_t;
class C; function int g(int x); return x; endfunction function void f(); s_t s; void'(g(s.a++)); endfunction endclass
