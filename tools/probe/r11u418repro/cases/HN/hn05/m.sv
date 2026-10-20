// § hoistNetsFirstModule418
module sub (input logic a);
  import p::*;
endmodule
module top;
  import p::*;
  logic x;
  sub u (.a(x));
endmodule
