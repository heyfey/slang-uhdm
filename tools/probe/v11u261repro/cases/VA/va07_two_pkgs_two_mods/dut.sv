// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
  parameter logic [7:0] W8 = 8'd12;
endpackage
package hq;
  parameter int NumRound = 16;
endpackage
module sa import hp::*; (input logic clk);
  logic [$clog2(NumRound)-1:0] ra;
endmodule
module sb import hq::*; (input logic clk);
  logic [$clog2(NumRound)-1:0] rb;
endmodule
module top;
  sa a (.clk(1'b0));
  sb b (.clk(1'b0));
endmodule
