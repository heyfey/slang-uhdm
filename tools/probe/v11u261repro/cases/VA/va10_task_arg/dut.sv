// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
  parameter logic [7:0] W8 = 8'd12;
endpackage
module sha2 import hp::*; (input logic clk);
  task automatic t(input logic [$clog2(NumRound)-1:0] a);
    logic [$clog2(NumRound)-1:0] b;
    b = a;
  endtask
  initial t('0);
endmodule
module top;
  sha2 u (.clk(1'b0));
endmodule
