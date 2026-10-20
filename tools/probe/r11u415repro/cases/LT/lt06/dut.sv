// § pkgLetCallFuncCall415
package pex;
let pick(x, y) = x ? y : 1'b0;
endpackage
module top(input logic a, b, output logic o);
import pex::*;
always_comb begin
  o = pick(a, b);
end
endmodule
