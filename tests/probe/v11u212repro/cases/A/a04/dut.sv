// § anonMemberTdLastWriter212 — verifier: module names differing in case (Zeta and alpha): byte order puts Zeta first
typedef struct packed { logic [3:0] a; logic b; } in_t;
module alpha(input logic [4:0] d, output logic o);
  struct packed { in_t m_alpha; } w;
  always_comb w = d;
  assign o = w.m_alpha.b;
endmodule
module Zeta(input logic [4:0] d, output logic o);
  struct packed { in_t m_zeta; } w;
  always_comb w = d;
  assign o = w.m_zeta.b;
endmodule
