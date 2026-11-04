// § typedefParentLastWriter134
package p;
  typedef struct packed { logic [2:0] k; logic v; } r_t;
endpackage
module unused_mod;
  import p::*;
  r_t z;
endmodule
module top(input logic c, output logic [2:0] o);
  import p::*;
  r_t r;
  always_comb begin r.k = {3{c}}; r.v = c; end
  assign o = r.k;
endmodule
