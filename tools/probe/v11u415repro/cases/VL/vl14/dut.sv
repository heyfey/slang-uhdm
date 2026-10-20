// § pkgLetCallFuncCall415
package pex;
  let sum2(x, y) = x + y;
endpackage
module top(input logic [3:0] a, b, output logic [4:0] o);
  import pex::*;
  logic [4:0] r;
  always_comb begin
    r = sum2((a), b);
  end
  assign o = r;
endmodule
