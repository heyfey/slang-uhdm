// § ppMacroBodyLines160
`define E(n) \
`ifdef UVM \
  $display("uvm"); \
`else \
  $error("x"); \
`endif
module top(input logic clk);
  always @(posedge clk) begin
    `E("abc")
    $display("after");
  end
endmodule
