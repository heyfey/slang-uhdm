// r10vearl74 adversarial grid C — SHADOWING INSIDE ONE INSTANCE.  The fixed
// walk stops at the instance boundary but still crosses gen_scope -> module.
// If a gen-scope localparam SHADOWS a module-level one and our emitter does
// not fold the gen-scope one to a constant (the cast residue), the walk can
// still read the module-level parameter's encoding.  Does golden?
module vsh74 ();
  localparam int SD = 4 + 4;             // module level, UINT:8 on golden
  localparam int SU = 4 * 2;             // module level, INT:8 on golden
  logic [3:0] top_sd [SD];
  logic [3:0] top_su [SU];
  for (genvar gi = 0; gi < 1; gi++) begin : gb
    localparam int SD = int'(4 * 2);     // shadows SD; a CAST (our unfolded shape)
    localparam int SU = int'(4 + 4);     // shadows SU; a CAST
    logic [3:0] gen_sd [SD];
    logic [3:0] gen_su [SU];
  end
  for (genvar gj = 0; gj < 1; gj++) begin : gc
    localparam int SD = 4 * 2;           // shadows SD, FOLDABLE, other tag
    localparam int SU = 4 + 4;           // shadows SU, FOLDABLE, other tag
    logic [3:0] gc_sd [SD];
    logic [3:0] gc_su [SU];
  end
endmodule
