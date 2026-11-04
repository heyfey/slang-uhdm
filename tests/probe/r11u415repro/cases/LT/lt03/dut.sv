// § pkgLetCallFuncCall415
package pex;
let sum2(x, y) = x + y;
endpackage
module top(input logic [3:0] a, b, output logic [4:0] o);
assign o = pex::sum2(a, b);
endmodule
