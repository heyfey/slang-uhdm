// § anonMemberTdLastWriter212 — a struct typedef written in an unpacked anonymous struct
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [4:0] d, output logic o);
  struct { in_t p; in_t q; } v;
  assign v.p = d;
  assign v.q = d;
  assign o = v.q.b;
endmodule
