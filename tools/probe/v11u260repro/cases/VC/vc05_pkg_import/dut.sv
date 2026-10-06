// § castStructInstCopy260 (a package struct typedef wildcard-imported, cast unqualified in an instance)
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
endpackage
module m import p::*; (input logic [7:0] w, output logic [3:0] o);
  t_t r;
  assign r = t_t'(w);
  assign o = r.b;
endmodule
module top;
  logic [7:0] w; logic [3:0] o;
  m u (.w(w), .o(o));
endmodule
