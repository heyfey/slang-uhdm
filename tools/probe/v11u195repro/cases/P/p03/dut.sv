// § pkgPatMemberReadAtValue195 — v11u195 fresh: a macro-born member value from an included header, a real member and a sized literal member
`include "defs.svh"
package p;
  typedef struct { int A; real R; logic [7:0] S; } cfg_t;
  localparam cfg_t B = '{A:`VAL, R:1.5, S:8'hA5};
  localparam int WA = B.A;
  localparam real WR = B.R;
  localparam logic [7:0] WS = B.S;
endpackage
module top (input logic [p::WA-1:0] i, output logic o, output logic [7:0] s);
  assign o = i[0];
  assign s = p::WS;
endmodule
