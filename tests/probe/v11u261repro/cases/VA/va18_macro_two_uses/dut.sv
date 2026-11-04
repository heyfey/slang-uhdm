// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
  parameter logic [7:0] W8 = 8'd12;
endpackage
`define RW(n) logic [$clog2(NumRound)-1:0] n;
module sa import hp::*; (input logic clk);
  `RW(ra)
  `RW(rb)
endmodule
module top;
  sa a (.clk(1'b0));
endmodule
