// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter B = 4'b10x1;
  parameter C = B;
  parameter D = 4'bx + 1;
endpackage
module sub #(parameter W = 1)(input logic [3:0] a, output logic [3:0] o); assign o = a; endmodule
module top(input logic [3:0] a, output logic [3:0] o, output logic [3:0] q, output logic [3:0] r);
  import p::*;
  sub #(.W(1)) u(.a(a ^ C), .o(o));
  assign q = a ^ D;
  assign r = a & C;
endmodule
