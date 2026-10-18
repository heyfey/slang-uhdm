// § oobMacroDefAtExpansion402
package p;
class c;
  extern function void g_a();
  extern function void g_b();
  extern function void s_x();
endclass
`define G(T) function void c::g_``T(); endfunction
`G(a)
`G(b)
function void c::s_x(); endfunction
endpackage
module top; import p::*; c o; endmodule
