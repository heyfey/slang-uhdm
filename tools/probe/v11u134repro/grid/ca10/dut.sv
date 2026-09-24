// § contAssignLhsTsUnparented134
module top(input logic [7:0] i, output logic [3:0] o);
  typedef union packed { logic [7:0] b; struct packed { logic [3:0] h, l; } n; } u_t;
  u_t u;
  assign u = i;
  assign o = u.n.h;
endmodule
