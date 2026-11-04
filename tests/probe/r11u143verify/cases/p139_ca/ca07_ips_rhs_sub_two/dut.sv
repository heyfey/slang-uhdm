// § caLhsDefNetUnlessOpRhs139
// case ca07: an indexed part-select right-hand side in a sub-module instantiated twice
module sub(input logic [7:0] a, output logic [3:0] y);
  assign y = a[4 +: 4];
endmodule
module top(input logic [7:0] a, output logic [3:0] y1, output logic [3:0] y2);
  sub u1(.a(a), .y(y1));
  sub u2(.a(~a), .y(y2));
endmodule
