// § caAnySysCallLhsTs428
module top(input [7:0] x, output [3:0] y);
  assign y = $countbits(x, 1'b1);
endmodule
