// § incDecMemberPathIsLvalue124
typedef struct { int a; } i_t; typedef struct { i_t m; } j_t; typedef struct { j_t n; } k_t;
class C; function void f(); k_t k; k.n.m.a--; endfunction endclass
