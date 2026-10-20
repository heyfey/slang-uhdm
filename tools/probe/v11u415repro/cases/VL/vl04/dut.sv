// § pkgLetCallFuncCall415
package pex;
  let sum2(x, y) = x + y;
endpackage
module m1(input logic [3:0] a, b, output logic [4:0] o);
  import pex::*;
  assign o = sum2(a, b);
endmodule
module top(input logic [3:0] a, b, output logic [4:0] o1, o2);
  import pex::*;
  m1 u1(.a(a), .b(b), .o(o1));
  assign o2 = sum2(a, b);
endmodule
