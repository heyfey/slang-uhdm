// § ppMacroBodyLines160
`define E(n) \
`ifndef FPV \
  $error("x"); \
`endif
module top(input logic clk);
  always @(posedge clk) begin
    `E("abc")
  end
endmodule
