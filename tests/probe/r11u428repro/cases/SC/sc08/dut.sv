// § caAnySysCallLhsTs428
module top(input [3:0] x, output logic [3:0] y);
  assign y = $countones(4'b1011);
endmodule
