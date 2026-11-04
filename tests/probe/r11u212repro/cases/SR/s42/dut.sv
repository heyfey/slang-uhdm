// § anonMemberTdLastWriter212 — the module instantiated twice (two elaborated copies of one definition)
typedef struct packed { logic [3:0] a; logic b; } in_t;
module sub(input logic [4:0] d, output logic o);
  struct packed { in_t m; } w;
  assign w = d;
  assign o = w.m.b;
endmodule
module dut(input logic [9:0] d, output logic o);
  logic a, b;
  sub u1(.d(d[4:0]), .o(a));
  sub u2(.d(d[9:5]), .o(b));
  assign o = a ^ b;
endmodule
