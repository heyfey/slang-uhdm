// § anonMemberTdLastWriter212 — a variable typed by the typedef written only procedurally (no continuous assignment), beside the anonymous struct
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [9:0] d, output logic o);
  struct packed { in_t p; in_t q; } v;
  in_t z;
  assign v = d;
  always_comb z = d[4:0];
  assign o = v.q.b ^ z.b;
endmodule
