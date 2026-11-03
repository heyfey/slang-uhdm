// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
package u;
  import t::*;
  class C; vt_t h; function void f(vt_t x); h = x; endfunction endclass
endpackage
module top; import u::*; C c; endmodule
