// § typedefParentLastWriter134
package p;
  typedef struct packed { logic [3:0] x; } t;
endpackage
module leaf #(parameter int N = 1) (input logic c, output logic [3:0] o);
  import p::*;
  t v;
  always_comb v.x = {4{c}} ^ N[3:0];
  assign o = v.x;
endmodule
module top(input logic c, output logic [3:0] o1, o2);
  leaf #(1) u1(.c(c), .o(o1));
  leaf #(2) u2(.c(c), .o(o2));
endmodule
