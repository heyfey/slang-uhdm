// § anonMemberTdOwnerDef212v — verifier (the break of § anonMemberTdLastWriter212): one header declaring a typedef included in an interface (plain variable) and a module (anonymous struct)
interface ii;
`include "td.svh"
  in_t v;
endinterface
module dut(input logic [4:0] d, output logic o);
`include "td.svh"
  ii u();
  struct packed { in_t mz; } w;
  always_comb w = d;
  always_comb u.v = d;
  assign o = w.mz.b ^ u.v.b;
endmodule
