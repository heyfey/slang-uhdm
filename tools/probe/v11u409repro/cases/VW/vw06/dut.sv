// § defImpArithSize32_409
package p;
  parameter R = {4'd1, 4'd2};
  parameter T = 16'hffff * 16'h2;
endpackage
import p::*;
module top (output [15:0] o, output [31:0] o2);
  assign o = R;
  assign o2 = T;
endmodule
