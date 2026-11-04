// § castTsFile124
`define C(x) int'(x)
module top(input logic [7:0] a, output int o, output int p);
  assign o = `C(a);
  assign p = `C(a) + 1;
endmodule
