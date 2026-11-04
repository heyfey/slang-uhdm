// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
endpackage
module m1 import hp::*; (input logic clk);
  logic [$clog2(NumRound)-1:0] r1;
endmodule
module m2 import hp::*; (input logic clk);
  logic [$clog2(NumRound)-1:0] r2;
endmodule
module top;
  m1 u1 (.clk(1'b0));
  m2 u2 (.clk(1'b0));
endmodule
