// § pkgLetCallFuncCall415
package pex;
let sum2(x, y) = x + y;
endpackage
module top(input logic [3:0] a, b, output logic [4:0] o, p);
import pex::*;
assign o = sum2(a, b);
assign p = sum2(a, b);
endmodule
