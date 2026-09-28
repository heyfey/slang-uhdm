// § anonMemberTdLastWriter212 — verifier: module aa writes the $unit typedef in an anonymous struct; a later-named module zz declares a plain variable of it (procedural only)
typedef struct packed { logic [3:0] a; logic b; } in_t;
module aa(input logic [4:0] d, output logic o);
  struct packed { in_t ma; } w;
  always_comb w = d;
  assign o = w.ma.b;
endmodule
module zz(input logic [4:0] d, output logic o);
  in_t v;
  always_comb v = d;
  assign o = v.b;
endmodule
