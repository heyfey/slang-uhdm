// § typedefParentLastWriter134
package p;
  typedef struct packed { logic [3:0] x; logic y; } t;
endpackage
module a_mod import p::*; (input t i, output logic o);
  assign o = i.y;
endmodule
module m_mod (input logic c, output logic [3:0] o);
  import p::*;
  t v;
  always_comb begin v.x = {4{c}}; v.y = c; end
  assign o = v.x;
endmodule
module z_mod (input logic c, output logic [3:0] o);
  import p::t;
  t w;
  always_comb w = '{x: 4'h3, y: c};
  assign o = w.x;
endmodule
module top(input logic c, output logic o, output logic [3:0] o1, o2);
  p::t tt;
  always_comb tt = '{x: 4'h1, y: c};
  a_mod ua(.i(tt), .o(o));
  m_mod um(.c(c), .o(o1));
  z_mod uz(.c(c), .o(o2));
endmodule
