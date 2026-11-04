// § anonMemberTdOwnerDef212v — verifier: the header typedef in a top zz (plain variable) that instantiates a child aa (anonymous struct), both including the header
module zz(input logic [4:0] d, output logic o, output logic o2);
`include "td.svh"
  in_t v;
  always_comb v = d;
  assign o = v.b;
  aa u(.d(d), .o(o2));
endmodule
module aa(input logic [4:0] d, output logic o);
`include "td.svh"
  struct packed { in_t ma; } w;
  always_comb w = d;
  assign o = w.ma.b;
endmodule
