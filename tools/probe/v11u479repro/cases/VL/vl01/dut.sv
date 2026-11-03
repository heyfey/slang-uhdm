// § pkgVifLocalBareCopy479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*;
  task automatic tk(); vt_t g; endtask
endmodule
