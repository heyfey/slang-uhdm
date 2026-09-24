// § incDecMemberPathIsLvalue124
typedef struct { int a; int b; } s_t;
class C; s_t q [4]; function void f(int i); q[i].a++; endfunction endclass
