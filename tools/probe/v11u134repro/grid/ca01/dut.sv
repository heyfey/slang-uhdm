// § contAssignLhsTsUnparented134
package p;
  typedef struct packed { logic [3:0] x; logic y; } t;
endpackage
module sub import p::*; (input logic c, output t o);
  assign o = '{x: 4'h5, y: c};
endmodule
module top(input logic c, output logic [3:0] ox);
  p::t w;
  sub s(.c(c), .o(w));
  assign ox = w.x;
endmodule
