// § pkgPatMemberReadAtValue195 — v11u195 fresh: a member value that is another package parameter's name
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam int unsigned L = 3;
  localparam cfg_t B = '{A:2, D:L};
  localparam int W = B.D;
endpackage
module top (input logic [p::W-1:0] i, output logic o);
  assign o = i[0];
endmodule
