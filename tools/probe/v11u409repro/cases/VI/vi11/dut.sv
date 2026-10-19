// § modImpTdParamTsClone409
package p;
  typedef byte b_t;
  typedef bit u_t;
  parameter b_t B = 8'd4;
  parameter u_t U = 1'b1;
endpackage
import p::*;
module top (output [7:0] o, output o2);
  assign o = B;
  assign o2 = U;
endmodule
