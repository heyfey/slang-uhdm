// § typedefParentLastWriter134
package p;
  typedef struct packed { logic [3:0] x; logic y; } t;
endpackage
module m1(input logic c, output logic [3:0] o);
  import p::*;
  t v;
  always_comb v = '{x: {4{c}}, y: c};
  assign o = v.x;
endmodule
module top(input logic c, output logic [3:0] o1, o2);
  m1 a(.c(c), .o(o1));
  m1 b(.c(~c), .o(o2));
endmodule
