// § contAssignLhsTsUnparented134
module top(input logic c, output logic [3:0] o);
  typedef struct packed { logic [3:0] x; logic y; } s_t;
  wire s_t w = '{x: 4'h9, y: 1'b0};
  s_t v;
  assign v = w;
  assign o = v.x ^ {4{c}};
endmodule
