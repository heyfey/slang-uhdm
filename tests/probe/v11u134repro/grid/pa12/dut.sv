// § typedefParentLastWriter134
package p;
  typedef struct packed { logic [3:0] x; logic y; } t;
  typedef enum logic [1:0] { A, B } e_t;
endpackage
module m1 import p::*; #(parameter e_t E = A) (input logic c, output logic [3:0] o);
  t v;
  always_comb v = '{x: {4{c}} ^ E, y: c};
  assign o = v.x;
endmodule
module top(input logic c, output logic [3:0] o1, o2);
  m1 #(p::A) a(.c(c), .o(o1));
  m1 #(p::B) b(.c(c), .o(o2));
endmodule
