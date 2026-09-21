// r11v81 adversarial arm v2 — UNTYPED PACKAGE STORES THE GRID NEVER SHOWED:
// a string, a width-1 based literal, a concatenation, a ternary, a system
// call, zero, a negated hex and a 96-bit based literal.
package v2p;
  localparam SS  = "ab";
  localparam TT  = 1'b1;
  localparam CC  = {8'h5, 8'h6};
  localparam QQ  = (1 ? 5 : 6);
  localparam FF  = $clog2(16);
  localparam ZZ  = 0;
  localparam NH  = -16'h5;
  localparam W96 = 96'hF;
  localparam int TI = 5;
  localparam UT  = TI;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] s; logic [23:0] t; logic [23:0] c;
    logic [23:0] q;    logic [23:0] f; logic [23:0] z; logic [23:0] n;
    logic [23:0] w;    logic [23:0] u;
  } t2;
  localparam t2 B = '{bail: 8'hxA, s: SS, t: TT, c: CC, q: QQ, f: FF,
                      z: ZZ, n: NH, w: W96, u: UT};
endpackage
module v2_store81 #(parameter v2p::t2 CB = v2p::B) (output logic [23:0] o);
  assign o = CB.s ^ CB.t ^ CB.c ^ CB.q ^ CB.f ^ CB.z ^ CB.n ^ CB.w ^ CB.u;
endmodule
