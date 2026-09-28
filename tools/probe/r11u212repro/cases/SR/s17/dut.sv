// § anonMemberTdLastWriter212 — a package typedef written in a module's anonymous struct
package pk;
  typedef struct packed { logic [3:0] a; logic b; } in_t;
endpackage
module dut(input logic [9:0] d, output logic o);
  struct packed { pk::in_t p; pk::in_t q; } v;
  assign v = d;
  assign o = v.q.b;
endmodule
