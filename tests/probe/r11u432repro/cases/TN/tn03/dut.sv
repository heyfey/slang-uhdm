// § unitOobBodyRefChainName432
class C #(int p = 1, type T = int);
int q;
extern function T f(int a);
endclass
function C::T C::f(int a);
return a + q + p;
endfunction
