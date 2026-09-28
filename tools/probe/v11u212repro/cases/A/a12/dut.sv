// § anonMemberTdLastWriter212 — verifier: an enum typedef written as an anonymous member in two modules (base ref names)
typedef enum logic [1:0] { E0, E1, E2 } e_t;
module bb(input logic [1:0] d, output logic o);
  struct packed { e_t eb; logic x; } w;
  always_comb w = {d, 1'b0};
  assign o = w.eb == E1;
endmodule
module aa(input logic [1:0] d, output logic o);
  struct packed { e_t ea; } w;
  always_comb w = d;
  assign o = w.ea == E2;
endmodule
