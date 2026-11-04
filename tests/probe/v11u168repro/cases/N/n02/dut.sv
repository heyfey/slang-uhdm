// § ppOutputCol166
`define SHOW(x) $display(`"x`", x)
module top(input logic [3:0] a);
  initial `SHOW(a);
  initial $display("%0d", a);
endmodule
