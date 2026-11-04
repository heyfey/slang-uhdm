// § anonMemberTdLastWriter212 — nested anonymous structs: the typedef written in an inner anonymous struct member and in an outer member after it
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [14:0] d, output logic o);
  struct packed { struct packed { in_t ip; } inner; in_t outer; } v;
  assign v = d;
  assign o = v.outer.b ^ v.inner.ip.b;
endmodule
