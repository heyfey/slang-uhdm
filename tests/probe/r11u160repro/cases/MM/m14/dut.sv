// § ppMacroBodyLines160
`define FOO
`define E(n) \
`ifdef FOO \
  $error("foo %0s", n); \
`elsif BAR \
  $error("bar"); \
`else \
  $error("none"); \
`endif \
  $display("after");
module top(input logic clk);
  always @(posedge clk) begin
    `E("x")
  end
endmodule
