// § anonMemberTdLastWriter212 — a module-scope named struct typedef whose two members are written with another struct typedef
module dut(input logic [9:0] d, output logic o);
  typedef struct packed { logic [3:0] a; logic b; } in_t;
  typedef struct packed { in_t p; in_t q; } out_t;
  out_t v;
  assign v = d;
  assign o = v.q.b;
endmodule
