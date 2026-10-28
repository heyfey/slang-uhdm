// § ifcAnsiLogicPortNet450
interface bfm (input logic clk, output int x, output bit [3:0] b);
initial begin
  x = 0;
  b = 0;
end
endinterface
module top;
  logic clk; int xx; bit [3:0] bb;
  bfm u (.clk(clk), .x(xx), .b(bb));
endmodule
