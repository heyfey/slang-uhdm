// § anonMemberTdLastWriter212 — an anonymous struct as a port type
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input struct packed { in_t p; in_t q; } d, output logic o);
  assign o = d.q.b;
endmodule
