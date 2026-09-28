// § pkgPatMemberReadAtValue195 — v11u195 fresh: the pattern in another package, read through its qualifier
package q;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:2, D:8};
endpackage
package p;
  localparam int W = q::B.D;
endpackage
module top (input logic [p::W-1:0] i, output logic o);
  assign o = i[0];
endmodule
