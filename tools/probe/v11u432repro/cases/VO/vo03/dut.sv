// § unitOobBodyRefChainName432
localparam UP = 3;
int uvar;
class C;
int x;
extern function int f(int a);
endclass
function int C::f(int a);
return x + UP + uvar + a;
endfunction
