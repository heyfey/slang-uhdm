// § ndaUnsizedRhsFreshLhs438
module sub(input [15:0] b, output [1:0] y);
  wire logic signed [1:0] w = b['h1 +: 2];
  assign y = w;
endmodule
module top(input [15:0] b, output [1:0] y);
  sub u(.b(b), .y(y));
endmodule
