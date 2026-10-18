// § unitOobFuncOnDesign402
function int free1(); return 1; endfunction
class c;
extern function int f();
endclass
function int c::f(); return 2; endfunction
function int free2(); return 3; endfunction
module test;
endmodule
