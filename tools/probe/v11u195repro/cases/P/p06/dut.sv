// § pkgPatMemberReadAtValue195 — v11u195 fresh: a system-call member value and a parenthesized product
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:$clog2(16), D:(2*4)};
  localparam int WA = B.A;
  localparam int WD = B.D;
endpackage
module top (input logic [p::WA+p::WD-1:0] i, output logic o);
  assign o = i[0];
endmodule
