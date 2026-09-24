// § contAssignLhsTsUnparented134
module top(input logic c, output logic o);
  typedef struct packed { logic [3:0] x; logic y; } s_t;
  s_t a, b;
  assign {a, b} = {4'h1, c, 4'h2, c};
  assign o = a.y ^ b.y;
endmodule
