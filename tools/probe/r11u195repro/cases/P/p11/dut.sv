// § pkgPatMemberReadAtValue195 — grid P/p11 (r11u195)
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:2, D:8};
endpackage
module top (input logic [3:0] i, output logic o);
  localparam int W = p::B.D;
  assign o = i[W-8];
endmodule
