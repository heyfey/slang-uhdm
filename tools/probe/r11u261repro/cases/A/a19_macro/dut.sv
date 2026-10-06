// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
endpackage
`define RW(n) $clog2(n)
module sha2 import hp::*; (input logic clk);
  logic [`RW(NumRound)-1:0] round;
endmodule
module top;
  sha2 u (.clk(1'b0));
endmodule
