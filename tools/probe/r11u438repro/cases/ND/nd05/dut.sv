// § ifNdaUnsizedFreshLhs438
interface ifc(input [15:0] b);
  wire w = b['hA];
endinterface
module top(input [15:0] b, output y);
  ifc i(.b(b));
  assign y = i.w;
endmodule
