// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
  parameter logic [7:0] W8 = 8'd12;
endpackage
module sa import hp::*; (input logic clk);
  logic [$clog2(NumRound)-1:0] ra;
endmodule
