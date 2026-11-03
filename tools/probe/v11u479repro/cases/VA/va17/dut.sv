// § pkgVirtIfaceTd479
interface ifc #(parameter int W = 2) (input logic clk); logic [W-1:0] a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; vt_t h; endmodule
