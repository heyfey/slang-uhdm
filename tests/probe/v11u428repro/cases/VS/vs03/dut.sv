// § caAnySysCallLhsTs428
module top(input [7:0] x, output y);
  assign y = $isunknown(x);
endmodule
