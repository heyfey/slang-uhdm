// § anonMemberTdLastWriter212 — a struct typedef written in a union member
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [4:0] d, output logic o);
  union packed { in_t p; logic [4:0] q; } v;
  assign v = d;
  assign o = v.p.b;
endmodule
