// § connOpUnitParamFold433
parameter int K = 7;
module child(input [7:0] a, output [7:0] y);
  assign y = a;
endmodule
module top(input [7:0] x, output [7:0] y);
  child c(.a(x ^ K), .y(y));
endmodule
