// § pkgLetCallFuncCall415
module top(input logic [3:0] a, b, output logic [4:0] o);
let sum2(x, y) = x + y;
assign o = sum2(a, b);
endmodule
