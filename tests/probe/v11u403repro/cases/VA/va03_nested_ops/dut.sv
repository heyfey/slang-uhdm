// § operatorAttrsListed403
module top(input [3:0] a, b, c, output [3:0] y);
  assign y = (a + (* m = "x" *) b) - (* n *) c;
endmodule
