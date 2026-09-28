// § anonMemberTdLastWriter212 — r11u217 s05: a header included EARLY in the module body (before the module's own anonymous member) declaring an anonymous member on a header line LARGER than the module member's line (v11u212 a06's mirror: line order and declaration order disagree the other way)
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [4:0] d, output logic o, output logic o2);
`include "a05.svh"
  struct packed { in_t mlast; } w;
  always_comb w = d;
  always_comb h = d;
  assign o = w.mlast.b;
  assign o2 = h.mhdr.b;
endmodule
