// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
  parameter logic [7:0] W8 = 8'd12;
endpackage
module sha2 import hp::*; (input logic clk);
  logic [$clog2(NumRound)-1:0] round_q;
  always_ff @(posedge clk) round_q <= round_q + 1'b1;
  logic [$clog2(W8)-1:0] cnt;
endmodule
module top;
  sha2 u (.clk(1'b0));
endmodule
