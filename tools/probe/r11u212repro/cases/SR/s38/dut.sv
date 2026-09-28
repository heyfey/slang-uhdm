// § anonMemberTdLastWriter212 — a module bound into the top (bind) that declares an anonymous struct writing the typedef
typedef struct packed { logic [3:0] a; logic b; } in_t;
module chk(input logic [4:0] d);
  struct packed { in_t mchk; } w;
  assign w = d;
endmodule
module dut(input logic [9:0] d, output logic o);
  struct packed { in_t p; in_t q; } v;
  assign v = d;
  assign o = v.q.b;
endmodule
bind dut chk u_chk(.d(d[4:0]));
