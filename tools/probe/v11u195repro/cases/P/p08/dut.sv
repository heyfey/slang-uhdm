// § pkgPatMemberReadAtValue195 — v11u195 fresh: a narrower typed reader and a sized literal member
package p;
  typedef struct { logic [7:0] A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:8'h3, D:8};
  localparam logic [3:0] W = B.D;
  localparam int V = B.A;
endpackage
module top (input logic [p::W+p::V-1:0] i, output logic o);
  assign o = i[0];
endmodule
