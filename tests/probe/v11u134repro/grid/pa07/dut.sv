// § typedefParentLastWriter134
package p;
  typedef struct packed { logic [1:0] a; logic b; } in_t;
  typedef struct packed { in_t i; logic [3:0] d; } out_t;
endpackage
module zz(input logic c, output logic [1:0] o);
  import p::*;
  out_t v;
  always_comb begin v = '0; v.i.a = {c, c}; end
  assign o = v.i.a;
endmodule
module aa(input logic c, output logic [3:0] o);
  import p::out_t;
  out_t w;
  always_comb begin w = '0; w.d = {4{c}}; end
  assign o = w.d;
endmodule
module top(input logic c, output logic [1:0] o1, output logic [3:0] o2);
  zz u1(.c(c), .o(o1));
  aa u2(.c(c), .o(o2));
endmodule
