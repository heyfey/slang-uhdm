// § anonMemberTdLastWriter212 — verifier: a $unit class with an anonymous struct property writing the typedef, beside a module anonymous struct
typedef struct packed { logic [3:0] a; logic b; } in_t;
class cc;
  struct packed { in_t mc; } cv;
endclass
module dut(input logic [4:0] d, output logic o);
  struct packed { in_t mm; } w;
  always_comb w = d;
  assign o = w.mm.b;
endmodule
