// § anonMemberTdLastWriter212 — verifier: two anonymous structs on one line, the second writing the typedef at a larger column
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [9:0] d, output logic o);
  struct packed { in_t x1; } x; struct packed { in_t y1; } y;
  always_comb begin x = d[4:0]; y = d[9:5]; end
  assign o = x.x1.b ^ y.y1.b;
endmodule
