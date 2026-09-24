// § typedefParentLastWriter134
// case a05: two importers named z_mod and a_mod, only z_mod reads members, instantiated in reverse order
package p;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } t;
endpackage
module z_mod(input logic [7:0] i, output logic [3:0] o);
  import p::*;
  t v;
  assign v = i;
  assign o = v.y;
endmodule
module a_mod(input logic [7:0] i, output logic [7:0] o);
  import p::*;
  t q;
  always_comb q = i;
  assign o = q;
endmodule
module top(input logic [7:0] i, output logic [3:0] o1, output logic [7:0] o2);
  a_mod a(.i(i), .o(o2));
  z_mod z(.i(i), .o(o1));
endmodule
