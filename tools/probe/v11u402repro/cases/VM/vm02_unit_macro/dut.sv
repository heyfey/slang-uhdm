// § oobMacroDefAtExpansion402
`define DEF_F(N) function void c::N(); endfunction
class c;
  extern function void b();
  extern function void a();
endclass
`DEF_F(a)
function void c::b(); endfunction
module top;
endmodule
