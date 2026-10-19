// § pkgTfMacroDefAtExpansion403
`define MK(T) function void C::m_``T``(); endfunction
package p;
class C;
  extern function void m_x();
  extern function void m_y();
  extern function void z();
endclass
function void C::z(); endfunction
`MK(x)
function void free1(); endfunction
`MK(y)
endpackage
module top; endmodule
