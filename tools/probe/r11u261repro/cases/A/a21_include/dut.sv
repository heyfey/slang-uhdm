// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
endpackage
module m1 import hp::*; (input logic clk);
`include "decl.svh"
endmodule
module m2 import hp::*; (input logic clk);
`include "decl.svh"
endmodule
module top;
  m1 u1 (.clk(1'b0));
  m2 u2 (.clk(1'b0));
endmodule
