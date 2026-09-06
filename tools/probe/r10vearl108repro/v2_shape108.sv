// r10v108 v2 — THE CARRIER-SHAPE AXIS.  The formal is fixed at the corpus's
// `parameter bit R = 0` and the actual is a bare struct-param reference; what
// varies is WHERE the instance lives and HOW MANY of them there are.
// MEASUREMENT ONLY.  The official uhdm-cmp is the sole judge.
package u108;
  typedef struct packed {
    logic [1:0] a;
    logic [1:0] b;
    logic [1:0] c;
    logic       d;
  } rsp_t;
  parameter rsp_t RSP  = '{a: 2'b01, b: 2'b01, c: 2'b10, d: 1'b0};
  parameter rsp_t RSP2 = '{a: 2'b11, b: 2'b00, c: 2'b01, d: 1'b1};
endpackage

module c2108 #(parameter bit R = 0) (output logic o);
  assign o = R;
endmodule

// the child's formal is used as a WIDTH and inside a replication
module c2w108 #(parameter bit R = 0, parameter int W = 4) (output logic [W-1:0] o);
  assign o = {W{R}};
endmodule

interface if108 #(parameter bit R = 0) ();
  logic x;
  assign x = R;
endinterface

// a MIDDLE module that passes its OWN struct localparam down one more level
module mid108 (output logic o);
  import u108::*;
  localparam rsp_t MLOC = '{a: 2'b10, b: 2'b01, c: 2'b11, d: 1'b1};
  c2108 #(.R(MLOC)) i_n (.o(o));
endmodule

// a middle module whose OWN struct FORMAL is the actual one level down
module mid2108 #(parameter u108::rsp_t P = '{default: 0}) (output logic o);
  c2108 #(.R(P)) i_p (.o(o));
endmodule

module v2_shape108
  import u108::*;
(
  output logic [12:0] o,
  output logic  [6:0] ow
);
  // 1 — two instances of ONE prim with DIFFERENT struct actuals
  c2108 #(.R(RSP))  i_1 (.o(o[0]));
  c2108 #(.R(RSP2)) i_2 (.o(o[1]));
  // 2 — the same prim with a LITERAL actual (control) and with NO override
  c2108 #(.R(1'b1)) i_3 (.o(o[2]));
  c2108             i_4 (.o(o[3]));
  // 3 — GEN-FOR scope
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi = gi + 1) begin : gfor
      c2108 #(.R(RSP)) i_g (.o(o[4 + gi]));
    end
  endgenerate
  // 4 — GEN-IF scope
  generate
    if (1) begin : gif
      c2108 #(.R(RSP2)) i_h (.o(o[6]));
    end
  endgenerate
  // 5 — one more hierarchy level down (module-local localparam actual)
  mid108 i_m (.o(o[7]));
  // 6 — the actual is the PARENT's own overridden struct FORMAL, overridden
  //     with an INLINE pattern
  mid2108 #(.P(rsp_t'{a: 2'b01, b: 2'b10, c: 2'b11, d: 1'b0})) i_q (.o(o[8]));
  // 7 — the actual is the PARENT's own overridden struct FORMAL, overridden
  //     with a bare package-param REFERENCE
  mid2108 #(.P(RSP2)) i_r (.o(o[9]));
  // 8 — an INTERFACE with the same formal
  if108 #(.R(RSP)) i_if ();
  assign o[10] = i_if.x;
  // 9 — POSITIONAL override on a multi-param child, the struct actual second
  c2w108 #(1'b0, 5) i_pos (.o(ow[4:0]));
  assign o[11] = ow[0];
  // 10 — TWO overrides on one instance, one of them the struct actual
  c2w108 #(.R(RSP), .W($bits(rsp_t))) i_two (.o(ow[6:0]));
  assign o[12] = ow[6];
endmodule
