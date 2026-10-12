// § delayParenInnerExprSpan292
package p;
  class c;
    int x;
    task t(int d);
      #( d ) x = 1;
      #/*c*/( d + 1 ) x = 2;
      x <= #( 4 ) 3;
    endtask
  endclass
endpackage
program prg(input logic clk);
  default clocking cb @(posedge clk); endclocking
  int y;
  initial begin
    ##( 2 ) y = 1;
    #( 3 ) y = 2;
  end
endprogram
module top(input logic clk);
  prg pp(.clk(clk));
endmodule
