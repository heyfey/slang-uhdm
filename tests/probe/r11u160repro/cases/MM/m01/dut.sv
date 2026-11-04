// § ppMacroBodyLines160
`define E(n) \
`ifdef UVM \
  $display("uvm %0s", n); \
  $display("uvm2"); \
`else \
  $error("x %0s", \
         n); \
`endif
module top(input logic clk);
  always @(posedge clk) begin
    `E("abc")
  end
endmodule
