// § incDecMemberPathIsLvalue124
typedef struct { int a; int b; } s_t; typedef struct { s_t in; int c; } o_t;
class C; function void f(); o_t o; o.in.a++; endfunction endclass
