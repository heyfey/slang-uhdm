// § caAnySysCallLhsTs428
module top(input [7:0] x, output [7:0] y);
  assign y = $urandom_range(3);
endmodule
