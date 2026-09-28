// § anonMemberTdLastWriter212 — one struct typedef written as members of two structs with different member names (the writer order)
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [9:0] d, output logic o);
  struct packed { in_t first; in_t second; } v;
  struct packed { in_t third; } w;
  assign v = d;
  assign w = d[4:0];
  assign o = v.second.b ^ w.third.b;
endmodule
