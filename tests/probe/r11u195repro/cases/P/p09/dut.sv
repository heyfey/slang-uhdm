// § pkgPatMemberReadAtValue195 — grid P/p09 (r11u195)
`include "defs.svh"
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:2, D:`DV};
  localparam int W = `RD;
endpackage
module top (input logic [p::W-1:0] i, output logic o);
  assign o = i[0];
endmodule
