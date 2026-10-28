// § ifcAnsiLogicPortNet450
package p;
  typedef struct packed { int a; logic b; } s_t;
  typedef struct packed { logic [3:0] a; logic b; } l_t;
endpackage
import p::*;
interface bfm (input logic clk, output s_t s, output l_t l);
initial begin
  s = 0;
  l = 0;
end
endinterface
module top;
  logic clk; s_t ss; l_t ll;
  bfm u (.clk(clk), .s(ss), .l(ll));
endmodule
