// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
  parameter logic [7:0] W8 = 8'd12;
endpackage
package q;
  import hp::*;
  typedef logic [$clog2(NumRound)-1:0] rnd_t;
endpackage
module sha2 (input logic clk);
  q::rnd_t round;
endmodule
module top;
  sha2 u (.clk(1'b0));
endmodule
