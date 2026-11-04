// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
  parameter logic [7:0] W8 = 8'd12;
endpackage
module leaf import hp::*; (input logic clk);
  logic [$clog2(NumRound)-1:0] r;
endmodule
module sha2 (input logic clk);
  for (genvar i = 0; i < 2; i++) begin : g
    leaf l (.clk(clk));
  end
endmodule
module top;
  sha2 u (.clk(1'b0));
endmodule
