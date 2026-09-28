// § anonMemberTdLastWriter212 — a module-scope typedef in module aa written in anonymous structs of aa, and a second module zz with its own same-named typedef
module zz(input logic [4:0] d, output logic o);
  typedef struct packed { logic [3:0] a; logic b; } in_t;
  struct packed { in_t mzz; } w;
  assign w = d;
  assign o = w.mzz.b;
endmodule
module aa(input logic [9:0] d, output logic o);
  typedef struct packed { logic [3:0] a; logic b; } in_t;
  struct packed { in_t p; in_t q; } v;
  logic t;
  assign v = d;
  zz u(.d(d[4:0]), .o(t));
  assign o = v.q.b ^ t;
endmodule
