// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
  parameter logic [7:0] W8 = 8'd12;
endpackage
module sha2 import hp::*; (input logic clk);
  logic [NumRound-1:0] round;
  logic [hp::W8:0] r2;
endmodule
module top;
  sha2 u (.clk(1'b0));
endmodule
