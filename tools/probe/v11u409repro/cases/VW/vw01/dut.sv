// § defImpArithSize32_409
package p;
  parameter R = 8'd3 + 8'd4;
endpackage
import p::*;
module top (output [7:0] o);
  assign o = R;
endmodule
