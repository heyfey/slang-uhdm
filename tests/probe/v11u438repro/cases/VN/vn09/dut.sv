// § ndaUnsizedRhsFreshLhs438
module sub(input [15:0] b, output y);
  wire [3:0] w = b['hB:'h8];
  assign y = w[0];
endmodule
module top(input [15:0] b, output [1:0] y);
  sub u0(.b(b), .y(y[0]));
  sub u1(.b(~b), .y(y[1]));
endmodule
