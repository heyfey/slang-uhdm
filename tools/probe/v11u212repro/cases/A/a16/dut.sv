// § anonMemberTdLastWriter212 — verifier: nets (wire) of anonymous struct type in two modules, no declaration assignment
typedef struct packed { logic [3:0] a; logic b; } in_t;
module aa(input logic [4:0] d, output logic o);
  wire struct packed { in_t na; } w;
  assign o = w.na.b;
endmodule
module bb(input logic [4:0] d, output logic o);
  wire struct packed { in_t nb; } w;
  assign o = w.nb.b ^ d[0];
endmodule
