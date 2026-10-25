// § unitOobBodyRefChainName432
class C;
typedef enum {E0, E1} e_t;
extern function e_t f(int a);
endclass
function C::e_t C::f(int a);
C::e_t r;
r = (a > 0) ? E1 : E0;
return r;
endfunction
