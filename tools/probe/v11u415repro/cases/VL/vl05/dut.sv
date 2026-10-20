// § pkgLetCallFuncCall415
package pex;
  let both(x, y) = x && y;
endpackage
module top(input logic clk, input logic a, b);
  import pex::*;
  assert property (@(posedge clk) both(a, b));
endmodule
