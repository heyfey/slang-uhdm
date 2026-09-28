// § anonMemberTdLastWriter212 — a module-scope struct typedef written twice in an anonymous struct in the same module
module dut(input logic [9:0] d, output logic o);
  typedef struct packed { logic [3:0] a; logic b; } in_t;
  struct packed { in_t p; in_t q; } v;
  assign v = d;
  assign o = v.q.b;
endmodule
