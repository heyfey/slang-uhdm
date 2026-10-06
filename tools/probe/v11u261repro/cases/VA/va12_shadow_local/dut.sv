// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
  parameter logic [7:0] W8 = 8'd12;
endpackage
module sha2 import hp::*; (input logic clk);
  localparam int NumRound = 8;
  logic [$clog2(NumRound)-1:0] round;
  logic [$clog2(W8)-1:0] w;
endmodule
module top;
  sha2 u (.clk(1'b0));
endmodule
