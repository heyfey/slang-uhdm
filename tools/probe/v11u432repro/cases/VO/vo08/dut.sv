// § unitOobBodyRefChainName432
class C;
extern function int f(int a);
endclass
function int C::f(int a);
automatic int t = a;
f = t;
endfunction
