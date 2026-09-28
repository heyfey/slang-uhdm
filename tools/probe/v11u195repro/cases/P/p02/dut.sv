// § pkgPatMemberReadAtValue195 — v11u195 fresh: the pattern in another package read through its qualifier, a system-call member value, a narrower typed reader
package q;
  typedef struct { int A; int D; } cfg_t;
  localparam cfg_t B = '{A:$clog2(16), D:12};
endpackage
package p;
  localparam int WA = q::B.A;
  localparam logic [3:0] WD = q::B.D;
endpackage
module top (input logic [p::WA-1:0] i, output logic o, output logic [3:0] d);
  assign o = i[0];
  assign d = p::WD;
endmodule
