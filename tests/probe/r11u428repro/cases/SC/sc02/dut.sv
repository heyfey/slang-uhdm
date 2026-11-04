// § caAnySysCallLhsTs428
module top(input [3:0] x, output [3:0] y);
  assign y = $countones(x);
endmodule
