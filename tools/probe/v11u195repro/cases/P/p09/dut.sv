// § pkgPatMemberReadAtValue195 — v11u195 fresh: a parenthesized product member value, one reader
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:2, D:(2*4)};
  localparam int W = B.D;
endpackage
module top (input logic [p::W-1:0] i, output logic o);
  assign o = i[0];
endmodule
