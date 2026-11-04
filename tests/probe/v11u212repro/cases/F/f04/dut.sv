// § anonMemberTdOwnerDef212v — verifier (the break of § anonMemberTdLastWriter212): one header declaring a module-scope typedef included in two modules; only the EARLIER-named one writes it in an anonymous struct
module aa(input logic [4:0] d, output logic o);
`include "td.svh"
  struct packed { in_t ma; } w;
  always_comb w = d;
  assign o = w.ma.b;
endmodule
module zz(input logic [4:0] d, output logic o);
`include "td.svh"
  in_t v;
  always_comb v = d;
  assign o = v.b;
endmodule
