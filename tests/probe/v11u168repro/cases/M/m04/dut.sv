// § ppOutputCol166
`define SHOW(x) \
  initial begin \
    $display(`"x=%0d`", x); \
  end
module top(input logic [3:0] a);
  `SHOW(a)
endmodule
