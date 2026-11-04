// § typedefParentLastWriter134
package p;
  typedef struct packed { logic a; logic [1:0] b; } s_t;
endpackage
package q;
  import p::*;
  typedef struct packed { s_t inner; logic c; } w_t;
endpackage
module top(input logic c, output logic [1:0] o);
  import q::*;
  w_t w;
  always_comb begin w = '0; w.c = c; w.inner.b = {c, c}; end
  assign o = w.inner.b;
endmodule
