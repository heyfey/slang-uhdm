// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
endpackage
program prg import hp::*; (input logic clk);
  logic [$clog2(NumRound)-1:0] cnt;
endprogram
module top;
  logic c;
  prg p (.clk(c));
endmodule
