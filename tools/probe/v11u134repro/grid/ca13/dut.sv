// § contAssignLhsTsUnparented134
module leaf #(parameter int W = 2) (input logic c, output logic [W-1:0] o);
  typedef struct packed { logic [W-1:0] x; logic y; } s_t;
  s_t s;
  assign s = '{x: {W{c}}, y: c};
  assign o = s.x;
endmodule
module top(input logic c, output logic [1:0] o1, output logic [3:0] o2);
  leaf #(2) u1(.c(c), .o(o1));
  leaf #(4) u2(.c(c), .o(o2));
endmodule
