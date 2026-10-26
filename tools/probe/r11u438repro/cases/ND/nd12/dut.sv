// § ifNdaUnsizedFreshLhs438
interface ifc(input [15:0] b);
  wire [3:0] w = b['h7:'h4];
endinterface
module top(input [15:0] b, output [3:0] y1, y2);
  ifc i1(.b(b));
  ifc i2(.b(b));
  assign y1 = i1.w;
  assign y2 = i2.w;
endmodule
