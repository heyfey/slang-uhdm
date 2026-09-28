// § anonMemberTdLastWriter212 — an output port typed by the typedef, continuously assigned, beside the anonymous struct
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [9:0] d, output in_t o);
  struct packed { in_t p; in_t q; } v;
  assign v = d;
  assign o = v.q;
endmodule
