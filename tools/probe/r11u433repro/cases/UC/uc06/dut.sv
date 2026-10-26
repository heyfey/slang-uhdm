// § connOpUnitParamFold433
localparam S = 2;
module child(input [7:0] a, output [7:0] y);
  assign y = a;
endmodule
module top(input [7:0] x, output [7:0] y);
  child c(.a(S), .y(y));
  child d(.a(x[S]), .y());
endmodule
