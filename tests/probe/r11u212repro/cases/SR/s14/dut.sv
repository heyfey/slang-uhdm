// § anonMemberTdLastWriter212 — two uninstantiated top modules, each with an anonymous struct writing the typedef under a different member name
typedef struct packed { logic [3:0] a; logic b; } in_t;
module ta(input logic [4:0] d, output logic o);
  struct packed { in_t ma; } w;
  assign w = d;
  assign o = w.ma.b;
endmodule
module tb(input logic [4:0] d, output logic o);
  struct packed { in_t mb; } w;
  assign w = d;
  assign o = w.mb.b;
endmodule
