// § ppOutputLine166
`define ERR(n) \
`ifdef NOPE \
  $display("a"); \
  $display("b"); \
`else \
  $error("%s", n); \
`endif
module top(input clk);
  always @(posedge clk) begin
    `ERR("x")
  end
endmodule
