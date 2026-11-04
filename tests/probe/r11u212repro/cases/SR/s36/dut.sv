// § anonMemberTdLastWriter212 — the anonymous struct declared inside a macro body
typedef struct packed { logic [3:0] a; logic b; } in_t;
`define DECL(n) struct packed { in_t p; in_t n; } v;
module dut(input logic [9:0] d, output logic o);
  `DECL(qm)
  assign v = d;
  assign o = v.qm.b;
endmodule
