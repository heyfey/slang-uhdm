// G2: the concatenation-initialized array parameter in the top module.
module top(output int o);
  parameter int A3[0:2] = {1, 2, 3};
  assign o = A3[1];
endmodule
