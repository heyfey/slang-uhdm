// § incDecMemberPathIsLvalue124
typedef struct { int arr [4]; int b; } s_t;
class C; function void f(int i); s_t s; s.arr[i]++; endfunction endclass
