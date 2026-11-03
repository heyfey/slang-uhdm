// § pkgVirtIfaceTd479
interface ifc #(int W = 8) (input logic clk); logic [W-1:0] a; endinterface
package t;
  typedef virtual ifc #(.W(4)) vt_t;
endpackage
module top; import t::*; vt_t h; endmodule
