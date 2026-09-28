// § anonMemberTdLastWriter212 — verifier: module aa writes the typedef in an anonymous struct; a later-named module zz has an input port of the typedef
typedef struct packed { logic [3:0] a; logic b; } in_t;
module aa(input logic [4:0] d, output logic o);
  struct packed { in_t ma; } w;
  always_comb w = d;
  assign o = w.ma.b;
endmodule
module zz(input in_t p, output logic o);
  assign o = p.b;
endmodule
