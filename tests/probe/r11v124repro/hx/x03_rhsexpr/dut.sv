// § incDecMemberPathIsLvalue124
typedef struct { int a; int b; } s_t;
class C; function int f(); s_t s; int x; x = s.a++; return x; endfunction endclass
