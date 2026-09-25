// § ppMacroBodyLines160
`define E(n) \
  $error("%0s %0d %0s", `__FILE__, `__LINE__, \
         n);
module top(input logic clk);
  always @(posedge clk) begin
    `E("abc")
  end
endmodule
