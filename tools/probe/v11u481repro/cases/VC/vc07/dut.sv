// § pkgVifLocalInitCopy481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
package q; import t::*;
  function automatic void f(); vt_t g = null; endfunction
endpackage
module top; import q::*;
endmodule
