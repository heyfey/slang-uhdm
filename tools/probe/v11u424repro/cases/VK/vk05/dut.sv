// § boundSizedLitKept424
module sub #(parameter W = 4) (input [W-1:0] a);
  typedef logic ['d5:0] t6_t;
  t6_t q;
endmodule
module top; logic [3:0] a; sub s(a); endmodule
