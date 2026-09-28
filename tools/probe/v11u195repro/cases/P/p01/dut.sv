// § pkgPatMemberReadAtValue195 — v11u195 fresh: member values that are a parameter reference, a unary minus and a concatenation
package p;
  typedef struct { int A; int D; logic [7:0] C; } cfg_t;
  localparam int L = 3;
  localparam cfg_t B = '{A:L, D:-5, C:{4'h1, 4'h2}};
  localparam int WA = B.A;
  localparam int WD = B.D;
  localparam logic [7:0] WC = B.C;
endpackage
module top (input logic [p::WA-1:0] i, output logic o, output logic [7:0] c, output int d);
  assign o = i[0];
  assign c = p::WC;
  assign d = p::WD;
endmodule
