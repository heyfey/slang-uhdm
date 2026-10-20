// § pkgLetCallFuncCall415
package pex;
  let sum2(x, y) = x + y;
endpackage
module top(input logic [3:0] a, b);
  import pex::*;
  initial $display("%0d", sum2(a, b));
endmodule
