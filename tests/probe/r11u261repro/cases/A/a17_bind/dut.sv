// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
endpackage
module chk import hp::*; (input logic clk);
  logic [$clog2(NumRound)-1:0] cnt;
endmodule
module sha2 (input logic clk);
endmodule
module top;
  logic c;
  sha2 u (.clk(c));
  bind sha2 chk u_chk (.clk(clk));
endmodule
