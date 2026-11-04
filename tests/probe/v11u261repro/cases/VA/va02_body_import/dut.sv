// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
  parameter logic [7:0] W8 = 8'd12;
endpackage
module sha2 (input logic clk);
  import hp::*;
  logic [$clog2(NumRound)-1:0] round;
  assign round = '0;
endmodule
module top;
  sha2 u (.clk(1'b0));
endmodule
