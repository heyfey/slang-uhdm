// § ppMacroBodyLines160
`define S(x) `"x`"
module top(input logic clk);
  always @(posedge clk) $display("%s %s", `S(hello), `S(  spaced  ));
endmodule
