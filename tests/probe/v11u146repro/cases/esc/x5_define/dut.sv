// § escIdPpColumnShift146
`define W 4
module top(input [3:0] a, output [3:0] y);
  wire [`W-1:0] \s$x ; assign \s$x  = a; wire [`W-1:0] t = \s$x  & `W'hF; assign y = t;
endmodule
