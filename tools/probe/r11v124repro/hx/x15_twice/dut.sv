// § incDecMemberPathIsLvalue124
typedef struct { int a; int b; } s_t;
class C; function int g(int x, int y); return x+y; endfunction function void f(); s_t s; void'(g(s.a++, s.b)); endfunction endclass
