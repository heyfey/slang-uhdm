// § anonMemberTdLastWriter212 — verifier: module zz writes the typedef in an anonymous struct; an earlier-named module aa declares a plain variable of it
typedef struct packed { logic [3:0] a; logic b; } in_t;
module zz(input logic [4:0] d, output logic o);
  struct packed { in_t mz; } w;
  always_comb w = d;
  assign o = w.mz.b;
endmodule
module aa(input logic [4:0] d, output logic o);
  in_t v;
  always_comb v = d;
  assign o = v.b;
endmodule
