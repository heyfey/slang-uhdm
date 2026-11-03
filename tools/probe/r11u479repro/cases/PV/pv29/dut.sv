// § pkgVirtIfaceTd479
interface ifc #(int W = 8) (input logic clk); logic [W-1:0] a; endinterface
package t;
  localparam int P = 4;
  typedef virtual ifc #(P) vt_t;
endpackage
module top; import t::*; vt_t h; endmodule
