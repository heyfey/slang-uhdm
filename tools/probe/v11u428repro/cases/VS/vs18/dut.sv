// § caAnySysCallLhsTs428
module top(input [7:0] x, output [1:0] a, output [1:0] b);
  assign {a, b} = $countones(x);
endmodule
