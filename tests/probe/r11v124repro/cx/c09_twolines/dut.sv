// § castTsFile124
module top(input logic [7:0] a, output int o, output int p);
  assign o = int'(a);
  assign p = int'(a);
endmodule
