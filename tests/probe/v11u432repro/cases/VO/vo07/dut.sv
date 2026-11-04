// § unitOobBodyArgRefUnbound432
class C;
extern function void f(output int o, input int a);
endclass
function void C::f(output int o, input int a);
logic [7:0] v;
v = a;
o = v[3:0] + v[1];
endfunction
