// § incDecMemberPathIsLvalue124
typedef struct { int a; int b; } s_t;
class C; s_t s; function void f(); s.a++; this.s.b++; endfunction endclass
