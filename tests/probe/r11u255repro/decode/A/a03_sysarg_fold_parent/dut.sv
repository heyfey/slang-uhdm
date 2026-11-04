// § sysFuncArgFold (decode only, ground A: Earlgrey_0_1 #136315 / #137760, an imported parameter folded as a $clog2 argument in a typespec range: golden parents the constant at the param_assign)
package hp;
  parameter int NumRound = 64;
endpackage
module sha2 import hp::*; (input logic clk);
  logic [$clog2(NumRound)-1:0] round;
endmodule
module top;
  sha2 u (.clk(1'b0));
endmodule
