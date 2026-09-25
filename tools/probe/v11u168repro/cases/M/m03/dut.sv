// § ppOutputLine166
`define REG(n) \
  logic [3:0] n``_q; \
  always_ff @(posedge clk) n``_q <= n; \
  assign n``_o = n``_q;
module top(input logic clk, input logic [3:0] a, output logic [3:0] a_o);
  `REG(a)
endmodule
