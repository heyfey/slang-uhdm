// § castTsFile124
`define C2(x, y) \
  4'(x) + \
  int'(y)
module top(input logic [7:0] a, output int o);
  assign o = `C2(a, a);
endmodule
