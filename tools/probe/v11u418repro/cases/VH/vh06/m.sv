// § hoistNetsFirstModule418
import p::*;
module sub #(parameter N = 1) (input logic a);
endmodule
module top;
  logic x;
  sub #(1) u1 (.a(x));
  sub #(2) u2 (.a(x));
endmodule
