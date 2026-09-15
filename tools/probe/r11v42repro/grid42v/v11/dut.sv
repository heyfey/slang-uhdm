// v11u42 arm v11 — the DECIMAL-BASED literal at the MIXED builder (a select on
// the base), qualified and unqualified, where the landed § hpMixedIdxPkgFold34
// already folds.
package pz11;
  localparam logic [1:0]  SPD = 2'd1;
  localparam logic [3:0]  SPH = 4'hA;
  typedef struct packed { logic [15:0] m; logic [3:0] t; } s_t;
endpackage

module v11 (input logic [19:0] w20, output logic [63:0] o);
  import pz11::*;
  pz11::s_t arr [0:1];
  assign arr[0] = w20; assign arr[1] = w20;
  assign o[0] = arr[0].m[pz11::SPD+2];   // c01 mixed builder, QUALIFIED 'd
  assign o[1] = arr[0].m[SPD+2];         // c02 mixed builder, imported 'd
  assign o[2] = arr[0].m[pz11::SPH-1];   // c03 mixed builder, QUALIFIED 'h
  assign o[3] = arr[0].m[SPH-1];         // c04 mixed builder, imported 'h
endmodule
