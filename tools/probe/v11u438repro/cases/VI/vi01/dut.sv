// § ifNdaUnsizedFreshLhs438
interface ifc(input [15:0] b);
  wire w = b['h1];
endinterface
module top(input [15:0] b, output y, z);
  ifc i0(b);
  ifc i1(~b);
  assign y = i0.w;
  assign z = i1.w;
endmodule
