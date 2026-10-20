// § pkgLetCallFuncCall415
package pex;
let sum2(x, y) = x + y;
endpackage
module top(input logic [3:0] a, b, output logic [4:0] o);
import pex::sum2;
always_comb o = sum2(a, b) + 1;
endmodule
