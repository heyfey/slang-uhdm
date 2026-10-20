// § hoistNetsFirstModule418
import p::*;
module sub (input logic a);
endmodule
module top;
  logic x;
  sub u1 (.a(x));
  sub u2 (.a(x));
endmodule
