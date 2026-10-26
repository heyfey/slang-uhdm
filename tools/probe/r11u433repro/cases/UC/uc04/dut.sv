// § connOpUnitParamFold433
localparam [3:0] M = 4'd9;
module child(input [7:0] a, output [7:0] y);
  assign y = a;
endmodule
module top(input [7:0] x, output [7:0] y);
  child c(.a(x & M), .y(y));
endmodule
