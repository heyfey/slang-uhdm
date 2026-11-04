// § anonMemberTdLastWriter212 — a $unit struct typedef written twice in one anonymous packed struct (anon_struct_packed_dim's shape)
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [9:0] d, output logic o);
  struct packed { in_t p; in_t q; } v;
  assign v = d;
  assign o = v.q.b;
endmodule
