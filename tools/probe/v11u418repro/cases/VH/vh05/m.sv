// § hoistNetsFirstModule418
import p::*;
module top;
  logic x;
  bsub u (.a(x));
endmodule
module bsub (input logic a);
  logic v;
endmodule
