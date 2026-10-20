// § hoistNetsFirstModule418
import p::*;
module leaf (input logic a);
endmodule
module amid (input logic a);
  leaf l (.a(a));
endmodule
module top;
  logic x;
  amid u (.a(x));
endmodule
