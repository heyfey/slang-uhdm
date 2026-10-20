// § hoistNetsFirstModule418
import p::*;
interface aif (input logic clk);
endinterface
module top;
  logic x;
  aif u (.clk(x));
endmodule
