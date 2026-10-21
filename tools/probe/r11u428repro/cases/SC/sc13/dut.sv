// § caAnySysCallLhsTs428
module top(input [3:0] x, input [3:0] z, output o);
  assign o = $onehot(x ^ z);
  wire p = $isunknown(x);
endmodule
