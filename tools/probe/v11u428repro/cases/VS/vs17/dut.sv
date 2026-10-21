// § caAnySysCallLhsTs428
module top(input [7:0] x, output [1:0][3:0] y);
  for (genvar i = 0; i < 2; i++) begin: g
    assign y[i] = $countones(x);
  end
endmodule
