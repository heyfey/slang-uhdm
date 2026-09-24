// § contAssignLhsTsUnparented134
package p;
  typedef struct packed { logic [3:0] x; logic y; } t;
endpackage
module top(input logic c, output logic [3:0] o2);
  import p::*;
  t q = '{x: 4'h1, y: 1'b0};
  assign o2 = q.x ^ {4{c}};
endmodule
