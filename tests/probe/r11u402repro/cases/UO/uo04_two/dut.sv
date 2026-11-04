// § unitOobFuncOnDesign402
class a; extern function int f(); endclass
class b; extern function int g(); endclass
function int b::g(); return 2; endfunction
function int a::f(); return 1; endfunction
module test;
endmodule
