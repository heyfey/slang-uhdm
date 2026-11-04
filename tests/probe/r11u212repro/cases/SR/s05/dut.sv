// § anonMemberTdLastWriter212 — a struct typedef written as a member and also as a plain variable type after it
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [9:0] d, output logic o);
  struct packed { in_t p; in_t q; } v;
  in_t z;
  assign v = d;
  assign z = d[4:0];
  assign o = v.q.b ^ z.b;
endmodule
