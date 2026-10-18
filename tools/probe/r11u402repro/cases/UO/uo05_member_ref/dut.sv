// § unitOobFuncOnDesign402
class c;
int x;
extern function int get(int a);
endclass
function int c::get(int a); return x + a; endfunction
module test;
endmodule
