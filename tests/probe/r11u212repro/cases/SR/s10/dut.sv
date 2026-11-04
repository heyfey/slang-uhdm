// § anonMemberTdLastWriter212 — two modules each with an anonymous struct writing the $unit typedef under different member names
typedef struct packed { logic [3:0] a; logic b; } in_t;
module sub(input logic [4:0] d, output logic o);
  struct packed { in_t m; } w;
  assign w = d;
  assign o = w.m.b;
endmodule
module dut(input logic [9:0] d, output logic o);
  struct packed { in_t p; in_t q; } v;
  logic t;
  assign v = d;
  sub u(.d(d[4:0]), .o(t));
  assign o = v.q.b ^ t;
endmodule
