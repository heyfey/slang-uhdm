// § anonMemberTdLastWriter212 — the typedef written in an anonymous union nested in an anonymous struct
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [9:0] d, output logic o);
  struct packed { union packed { in_t up; logic [4:0] raw; } u; in_t q; } v;
  assign v = d;
  assign o = v.q.b;
endmodule
