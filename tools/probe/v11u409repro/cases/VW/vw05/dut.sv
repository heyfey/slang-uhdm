// § defImpArithSize32_409
package p;
  parameter bit [7:0] A = 8'd9;
  parameter R = A & 8'h0f;
  parameter signed S = A + 1;
endpackage
import p::*;
module top (output [7:0] o, output [31:0] o2);
  assign o = R;
  assign o2 = S;
endmodule
