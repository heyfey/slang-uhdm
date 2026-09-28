// § anonMemberTdLastWriter212 — verifier a14: the child module in the second root file
module kid(input logic [4:0] d, output logic o);
  struct packed { in_t mk; } w;
  always_comb w = d;
  assign o = w.mk.b;
endmodule
