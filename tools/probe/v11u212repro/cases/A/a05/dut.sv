// § anonMemberTdLastWriter212 — verifier: module names mod9 and mod10 (byte order against natural order)
typedef struct packed { logic [3:0] a; logic b; } in_t;
module mod9(input logic [4:0] d, output logic o);
  struct packed { in_t m9; } w;
  always_comb w = d;
  assign o = w.m9.b;
endmodule
module mod10(input logic [4:0] d, output logic o);
  struct packed { in_t m10; } w;
  always_comb w = d;
  assign o = w.m10.b;
endmodule
