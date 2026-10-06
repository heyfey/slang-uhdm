// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
  parameter logic [7:0] W8 = 8'd12;
endpackage
module sha2 import hp::*; #(parameter int P = 1) (input logic clk);
  logic [$clog2(NumRound)-1:0] round;
  logic [P-1:0] z;
endmodule
module top;
  sha2 #(.P(2)) u1 (.clk(1'b0));
  sha2 #(.P(3)) u2 (.clk(1'b0));
endmodule
