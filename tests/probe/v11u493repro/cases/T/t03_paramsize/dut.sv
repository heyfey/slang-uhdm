// § enumCastChainKeepsInnerCast493
module top(input logic [7:0] a, output logic [7:0] w);
  localparam int W = 8;
  assign w = 8'(W'(a));
endmodule
