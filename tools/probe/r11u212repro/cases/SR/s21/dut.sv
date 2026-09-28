// § anonMemberTdLastWriter212 — an input port typed by the typedef beside the anonymous struct
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input in_t d, output logic o);
  struct packed { in_t p; in_t q; } v;
  assign v = {d, d};
  assign o = v.q.b;
endmodule
