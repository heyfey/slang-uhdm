// § incDecMemberPathIsLvalue124
typedef struct { int a; int b; } s_t;
class C; function void f(); s_t s; s.a += 1; s.b -= 2; endfunction endclass
