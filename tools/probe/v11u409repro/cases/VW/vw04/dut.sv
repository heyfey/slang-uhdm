// § defImpArithSize32_409
package p;
  parameter R = 4'd3 - 4'd5;
endpackage
import p::*;
module top (output [7:0] o);
  assign o = R;
endmodule
