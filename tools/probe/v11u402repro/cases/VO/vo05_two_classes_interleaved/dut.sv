// § unitOobFuncOnDesign402
class a;
  extern function int fa();
endclass
class b;
  extern function int fb();
endclass
function int b::fb(); return 2; endfunction
function automatic int free_f(); return 0; endfunction
function int a::fa(); return 1; endfunction
module top;
endmodule
