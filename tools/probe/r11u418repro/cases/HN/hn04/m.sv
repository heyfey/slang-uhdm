// § hoistNetsFirstModule418
import p::*;
module asub (input logic a);
  logic v;
endmodule
module top;
  logic x;
  asub u (.a(x));
endmodule
