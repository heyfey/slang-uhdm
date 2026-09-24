// § incDecMemberPathIsLvalue124
typedef struct { int a; int b; } s_t; typedef struct { s_t in; int c; } o_t;
class C; function int f(); s_t s; return s.a + 1; endfunction endclass
