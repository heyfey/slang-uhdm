// § unitOobBodyRefChainName432
class D; int v; endclass
class C;
D d;
int arr[4];
extern function int f();
extern function int g();
endclass
function int C::g(); return 1; endfunction
function int C::f();
d = new;
return d.v + arr[1] + g() + this.arr[2];
endfunction
