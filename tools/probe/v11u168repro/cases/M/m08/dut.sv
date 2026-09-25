// § ppOutputLine166
`define L2(y) \
  assign y = \
    `__LINE__;
module top(output int y);
  `L2(y)
endmodule
