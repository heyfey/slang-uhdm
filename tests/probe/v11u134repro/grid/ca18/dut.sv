// § contAssignLhsTsUnparented134
package p;
  typedef struct packed { logic [3:0] x; logic y; } t;
endpackage
module top import p::*; (input logic c, output t o);
  assign o = '{x: 4'h2, y: c};
endmodule
