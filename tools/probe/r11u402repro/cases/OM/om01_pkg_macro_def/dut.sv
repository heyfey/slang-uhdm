// § oobMacroDefAtExpansion402
package p;
class c;
  extern function int f1();
  extern function int f2();
  extern function int f3();
endclass
function int c::f1(); return 1; endfunction
`define MK(N) function int c::f``N(); return N; endfunction
`MK(2)
function int c::f3(); return 3; endfunction
endpackage
module top; import p::*; c o; endmodule
