// § anonMemberTdLastWriter212 — verifier: a header included late in the module body declares an anonymous struct on a header line smaller than the module variable line
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [4:0] d, output logic o, output logic o2);
  // padding
  // padding
  // padding
  // padding
  struct packed { in_t mfirst; } w;
  always_comb w = d;
  assign o = w.mfirst.b;
`include "a06.svh"
endmodule
