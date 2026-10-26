// § ndaUnsizedRhsFreshLhs438
module sub(input [15:0] b, output [4:0] y);
  wire [4:0] w = $countones(b['hF:'h0]);
  assign y = w;
endmodule
module top(input [15:0] b, output [4:0] y);
  sub u(.b(b), .y(y));
endmodule
