// § anonMemberTdLastWriter212 — a top named aa instantiating a child named zz: two children zz and yy
typedef struct packed { logic [3:0] a; logic b; } in_t;
module aa(input logic [9:0] d, output logic o);
  struct packed { in_t maa; } v;
  logic t1, t2;
  assign v = d[4:0];
  zz u1(.d(d[9:5]), .o(t1));
  yy u2(.d(d[9:5]), .o(t2));
  assign o = v.maa.b ^ t1 ^ t2;
endmodule
module zz(input logic [4:0] d, output logic o);
  struct packed { in_t mzz; } w;
  assign w = d;
  assign o = w.mzz.b;
endmodule
module yy(input logic [4:0] d, output logic o);
  struct packed { in_t myy; } w;
  assign w = d;
  assign o = w.myy.b;
endmodule
