// § delayParenInnerExprSpan292
interface ifc;
  logic clk;
  initial begin
    #( 2 ) clk = 0;
    #/*c*/(3) clk = 1;
  end
  task automatic t(); #(
    4 ) clk = 0; endtask
endinterface
module top; ifc i(); endmodule
