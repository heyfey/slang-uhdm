// § castTsDrainFile125
module top(input [3:0] x, input [1:0] y, output [2:0] o);
  assign o = 3'(x) | 2'(y);
endmodule
