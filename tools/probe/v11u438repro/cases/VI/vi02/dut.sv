// § ifNdaUnsizedFreshLhs438
interface ifc #(parameter P = 0) (input [15:0] b);
  wire [1:0] w = b['h2 + P +: 2];
endinterface
module top(input [15:0] b, output [1:0] y);
  ifc #(.P(3)) i0(b);
  assign y = i0.w;
endmodule
