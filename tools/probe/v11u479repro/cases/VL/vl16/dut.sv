// § pkgVifLocalBareCopy479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package t;
  typedef virtual ifc vt_t;
  class C; function new(); vt_t g; endfunction endclass
endpackage
module top; import t::*; C c; endmodule
