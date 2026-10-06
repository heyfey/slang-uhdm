// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
  parameter logic [7:0] W8 = 8'd12;
endpackage
module sha2 import hp::*; #(parameter int Q = NumRound) (input logic clk);
  logic [$clog2(NumRound)-1:0] round;
  logic [$clog2(Q)-1:0] q;
endmodule
module top;
  sha2 #(.Q(4)) u (.clk(1'b0));
endmodule
