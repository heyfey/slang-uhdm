// § ppOutputLine166
`define YES 1
`define ERR(n) \
`ifdef YES \
  $display("a", n); \
`else \
  $error("%s", n); \
  $error("%s", n); \
`endif
module top(input clk);
  always @(posedge clk) begin
    `ERR("x")
    $display("after");
  end
endmodule
