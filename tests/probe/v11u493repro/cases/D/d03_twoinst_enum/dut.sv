// § enumCastChainKeepsInnerCast493
module m #(parameter int W = 2)(input int s);
  typedef enum logic [W-1:0] {I0, I1} e_t;
  typedef logic [W-1:0] w_t;
  e_t v;
  always_comb v = e_t'(w_t'(s));
endmodule
module top(input int s);
  m #(2) u2(s);
  m #(3) u3(s);
endmodule
