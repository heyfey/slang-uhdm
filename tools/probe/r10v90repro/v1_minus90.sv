// r10v90 v1 — THE `-:` (IndexedDown) GRID.  The implementer's four arms
// contain ZERO `-:` selects, yet the shipped call site is the RangeSelect
// INDEXED arm, which serves `+:` and `-:` identically
// (`VpiIndexedPartSelectType` 1 vs 2).  If golden treats the descending form
// differently, every `-:` cell the law fires on is a RIGHT->WRONG.
module snk4_90 (input logic [3:0] a_i);
endmodule
module snk2_90 (input logic [1:0] a_i);
endmodule
module snk1_90 (input logic a_i);
endmodule

module v1_minus90;
  localparam int          P4  = 4;   // signed int   -> the law fires
  localparam int          P2  = 2;
  localparam int unsigned Q4  = 4;   // int unsigned -> the law refuses
  localparam              U4  = 4;   // UNTYPED      -> the law refuses
  localparam bit signed [3:0] B4 = 4;
  localparam logic [7:0]  L4  = 4;
  logic [31:0] sig;

  for (genvar g = 1; g < 2; g++) begin : gs
    // ---- `-:` WIDTH slot, the shapes the law claims -------------------
    snk4_90 m01 (.a_i(sig[g*4+3 -: P4  ]));   // bare signed-int localparam
    snk4_90 m02 (.a_i(sig[g*4+3 -: Q4  ]));   // int unsigned
    snk4_90 m03 (.a_i(sig[g*4+3 -: U4  ]));   // untyped
    snk4_90 m04 (.a_i(sig[g*4+3 -: B4  ]));   // bit signed [3:0]
    snk4_90 m05 (.a_i(sig[g*4+3 -: L4  ]));   // logic [7:0] (unsigned)
    snk4_90 m06 (.a_i(sig[g*4+3 -: P2*2]));   // EXPRESSION width
    snk4_90 m07 (.a_i(sig[g*4+3 -: 4   ]));   // LITERAL width
    snk4_90 m08 (.a_i(sig[g*4+3 -: g+3 ]));   // GENVAR-bearing width
    // ---- `-:` BASE slot ------------------------------------------------
    snk4_90 m09 (.a_i(sig[P4+3  -: 4   ]));
    snk4_90 m10 (.a_i(sig[P4+3  -: P4  ]));   // BOTH slots
    // ---- a LITERAL base with a param width, `-:` -----------------------
    snk4_90 m11 (.a_i(sig[7     -: P4  ]));
    snk2_90 m12 (.a_i(sig[g*2+1 -: P2  ]));
  end

  // the SAME reads in a PLAIN (non-generate) home — the fold arm is not armed
  snk4_90 m13 (.a_i(sig[7 -: P4]));
  snk4_90 m14 (.a_i(sig[7 +: P4]));
endmodule
