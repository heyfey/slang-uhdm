// § contAssignLhsTsUnparented134
package p;
  typedef struct packed { logic [3:0] x; logic y; } t;
endpackage
module a_mod(input logic c, output logic [3:0] o);
  p::t v;
  always_comb v = '{x: {4{c}}, y: c};
  assign o = v.x;
endmodule
module b_mod(input logic c, output logic [3:0] o);
  import p::*;
  t w;
  assign w = '{x: 4'h1, y: c};
  assign o = w.x;
endmodule
module top(input logic c, output logic [3:0] o1, o2);
  a_mod a(.c(c), .o(o1));
  b_mod b(.c(c), .o(o2));
endmodule
