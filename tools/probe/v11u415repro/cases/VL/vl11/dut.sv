// § pkgLetCallFuncCall415
package pex;
  let sum2(x, y) = x + y;
endpackage
module top(input logic [3:0] a, b, output logic [4:0] o [2]);
  import pex::*;
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = sum2(a, b);
  end
endmodule
