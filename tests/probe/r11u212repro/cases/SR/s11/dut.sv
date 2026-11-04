// § anonMemberTdLastWriter212 — the anonymous struct variable written only in an always_comb (no continuous assignment to it)
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [9:0] d, output logic o);
  struct packed { in_t p; in_t q; } v;
  always_comb v = d;
  assign o = v.q.b;
endmodule
