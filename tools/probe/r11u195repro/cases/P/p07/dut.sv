// § pkgPatMemberReadAtValue195 — grid P/p07 (r11u195)
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam int L = 3;
  localparam cfg_t B = '{A:2, D:8'(7)};
  localparam int W = B.D;
endpackage
module top (input logic [p::W-1:0] i, output logic o);
  assign o = i[0];
endmodule
