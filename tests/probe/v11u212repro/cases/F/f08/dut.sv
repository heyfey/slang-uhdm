// § anonMemberTdOwnerDef212v — verifier: a module-scope typedef written by a multi-line macro invoked in two modules, only the later-named one writing it in an anonymous struct
`define TD \
  typedef struct packed { logic [3:0] a; logic b; } in_t;
module aa(input logic [4:0] d, output logic o);
  `TD
  in_t v;
  always_comb v = d;
  assign o = v.b;
endmodule
module zz(input logic [4:0] d, output logic o);
  `TD
  struct packed { in_t mz; } w;
  always_comb w = d;
  assign o = w.mz.b;
endmodule
