// § ndaUnsizedRhsFreshLhs438
module sub(input [15:0] b, output [3:0] y);
  wire [3:0] w = b['h7:'h4];
  assign y = w;
endmodule
module top(input [15:0] b, output [3:0] y1, y2);
  sub u1(.b(b), .y(y1));
  sub u2(.b(b), .y(y2));
endmodule
