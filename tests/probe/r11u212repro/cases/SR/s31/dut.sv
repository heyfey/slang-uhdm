// § anonMemberTdLastWriter212 — a module-scope struct typedef written in an anonymous struct AND typing a continuously assigned variable
module dut(input logic [9:0] d, output logic o);
  typedef struct packed { logic [3:0] a; logic b; } in_t;
  struct packed { in_t p; in_t q; } v;
  in_t z;
  assign v = d;
  assign z = d[4:0];
  assign o = v.q.b ^ z.b;
endmodule
