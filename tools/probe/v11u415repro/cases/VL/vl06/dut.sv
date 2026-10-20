// § pkgLetCallFuncCall415
package pex;
  let sum2(x, y) = x + y;
endpackage
module m1(input logic [3:0] a, b, output logic [4:0] o);
  import pex::*;
  assign o = sum2(a, b);
endmodule
module top(input logic [3:0] c, d, output logic [4:0] o1, o2);
  m1 u1(.a(c), .b(d), .o(o1));
  m1 u2(.a(d), .b(c), .o(o2));
endmodule
