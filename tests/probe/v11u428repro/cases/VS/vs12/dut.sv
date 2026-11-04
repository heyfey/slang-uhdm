// § caAnySysCallLhsTs428
module top(input [7:0] x, output [7:0] y);
  logic [7:0] v;
  assign v = $countones(x);
  assign y = v;
endmodule
