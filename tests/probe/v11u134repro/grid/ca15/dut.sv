// § contAssignLhsTsUnparented134
module top(input logic c, output logic [3:0] o);
  typedef struct packed { logic [3:0] x; logic y; } s_t;
  typedef s_t s2_t;
  s2_t v;
  s_t w;
  assign v = '{x: 4'h7, y: c};
  always_comb w = v;
  assign o = w.x;
endmodule
