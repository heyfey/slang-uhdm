// § anonMemberTdLastWriter212 — a top named zz instantiating a child named aa declared after it (instance order against name order)
typedef struct packed { logic [3:0] a; logic b; } in_t;
module zz(input logic [9:0] d, output logic o);
  struct packed { in_t mzz; } v;
  logic t;
  assign v = d[4:0];
  aa u(.d(d[9:5]), .o(t));
  assign o = v.mzz.b ^ t;
endmodule
module aa(input logic [4:0] d, output logic o);
  struct packed { in_t maa; } w;
  assign w = d;
  assign o = w.maa.b;
endmodule
