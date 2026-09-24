// § incDecMemberPathIsLvalue124
typedef struct { int a; int b; } s_t;
class C; function void f(); s_t s; --s.b; endfunction endclass
