// § anonMemberTdOwnerDef212v — control: the header included once at compilation-unit scope ($unit typedef), two modules writing it in anonymous structs (the global last member stays)
`include "td.svh"
module aa(input logic [4:0] d, output logic o);
  struct packed { in_t ma; } w;
  always_comb w = d;
  assign o = w.ma.b;
endmodule
module zz(input logic [4:0] d, output logic o);
  in_t v;
  always_comb v = d;
  assign o = v.b;
endmodule
