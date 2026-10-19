// § operatorAttrsListed403
module top(input [3:0] a, b, output [3:0] y);
  assign y = a + (* w = 1 *) b;
endmodule
