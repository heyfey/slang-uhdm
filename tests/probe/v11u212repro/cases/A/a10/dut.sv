// § anonMemberTdLastWriter212 — verifier: a union typedef written as an anonymous struct member in two modules
typedef union packed { logic [4:0] a; logic [4:0] b; } un_t;
module aa(input logic [4:0] d, output logic o);
  struct packed { un_t ua; } w;
  always_comb w = d;
  assign o = w.ua.a[0];
endmodule
module bb(input logic [4:0] d, output logic o);
  struct packed { un_t ub; } w;
  always_comb w = d;
  assign o = w.ub.b[1];
endmodule
