// § anonMemberTdLastWriter212 — a program declaring an anonymous struct writing the typedef, beside the module's
typedef struct packed { logic [3:0] a; logic b; } in_t;
program pg(input logic [4:0] d);
  struct packed { in_t mpg; } w;
  initial w = d;
endprogram
module dut(input logic [9:0] d, output logic o);
  struct packed { in_t p; in_t q; } v;
  assign v = d;
  assign o = v.q.b;
  pg u_pg(.d(d[4:0]));
endmodule
