// § caAnySysCallLhsTs428
module top(input [3:0] x, output [2:0] y);
  if (1) begin: g
    assign y = $countones(x);
  end
endmodule
