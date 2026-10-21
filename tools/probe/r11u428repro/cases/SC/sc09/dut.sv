// § caAnySysCallLhsTs428
module top(input [3:0] x, output [7:0] y);
  assign y[2:0] = $countones(x);
endmodule
