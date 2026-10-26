// § ifNdaUnsizedFreshLhs438
interface ifc(input [15:0] b);
  logic [3:0] mem [0:1];
  assign mem[0] = b[3:0];
  wire [3:0] w = mem['h0];
endinterface
module top(input [15:0] b, output [3:0] y);
  ifc i0(b);
  assign y = i0.w;
endmodule
