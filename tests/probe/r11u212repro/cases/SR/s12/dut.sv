// § anonMemberTdLastWriter212 — the anonymous struct with a packed dimension, continuously assigned (anon_struct_packed_dim's content_q)
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [19:0] d, output logic o);
  struct packed { in_t p; in_t q; } [1:0] v;
  assign v = d;
  assign o = v[1].q.b;
endmodule
