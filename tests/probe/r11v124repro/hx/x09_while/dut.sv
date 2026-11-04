// § incDecMemberPathIsLvalue124
typedef struct { int a; int b; } s_t;
class C; function void f(); s_t s; while (s.a++ < 3) s.b = 1; endfunction endclass
