// § contAssignLhsTsUnparented134
package p;
  typedef struct packed { logic [3:0] x; logic y; } t;
endpackage
module top import p::*; (input logic c, output t o, output logic [3:0] o2);
  t q = '{x: 4'h1, y: 1'b0};
  assign o = '{x: 4'h2, y: c};
  assign o2 = q.x;
endmodule
