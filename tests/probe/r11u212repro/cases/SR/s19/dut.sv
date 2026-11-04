// § anonMemberTdLastWriter212 — two uninstantiated top modules declared in reverse name order (zb before za), each writing the typedef under its own member name
typedef struct packed { logic [3:0] a; logic b; } in_t;
module zb(input logic [4:0] d, output logic o);
  struct packed { in_t mzb; } w;
  assign w = d;
  assign o = w.mzb.b;
endmodule
module za(input logic [4:0] d, output logic o);
  struct packed { in_t mza; } w;
  assign w = d;
  assign o = w.mza.b;
endmodule
