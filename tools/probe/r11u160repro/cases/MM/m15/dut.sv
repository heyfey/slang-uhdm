// § ppMacroBodyLines160
`define E(n) \
`ifdef NOPE \
  `ifdef NOPE2 \
    $display("deep"); \
  `endif \
  $display("uvm"); \
`endif \
  $error("x %0s", n);
module top(input logic clk);
  always @(posedge clk) begin
    `E("abc")
  end
endmodule
