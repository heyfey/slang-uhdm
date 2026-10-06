// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
  parameter logic [7:0] W8 = 8'd12;
endpackage
module sha2 import hp::*; (input logic clk);
  logic [7:0] mem [$clog2(NumRound)];
  logic [3:0] m2 [0:$clog2(NumRound)-1];
endmodule
module top;
  sha2 u (.clk(1'b0));
endmodule
