// § anonMemberTdOwnerDef212v — verifier: one header declaring a module-scope ENUM typedef included in two modules, each writing it in an anonymous struct (the enum's base ref names)
module aa(input logic [1:0] d, output logic o);
`include "te.svh"
  struct packed { e_t ea; } w;
  always_comb w = d;
  assign o = w.ea == E1;
endmodule
module zz(input logic [1:0] d, output logic o);
`include "te.svh"
  struct packed { e_t ez; } w;
  always_comb w = d;
  assign o = w.ez == E2;
endmodule
