// § anonMemberTdLastWriter212 — the anonymous struct is a net (wire) with a declaration assignment
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [9:0] d, output logic o);
  wire struct packed { in_t p; in_t q; } v = d;
  assign o = v.q.b;
endmodule
