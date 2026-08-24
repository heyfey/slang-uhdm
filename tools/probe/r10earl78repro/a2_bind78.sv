// r10earl78 arm a2 — THE HEAD'S EXACT SHAPE: a GEN-SCOPE cont_assign whose Lhs
// is declared in the enclosing MODULE BODY (prim_ram_2p_async_adv's
// `logic [TotalWidth-1:0] a_wmask_d;` assigned from inside `gen_secded`).
// The ladder crosses the Lhs HOME (module body / gen-local / a module PORT /
// an implicit net / a SELECT) with natural-vs-target width, so the adjustSize
// clamp is measured where it can actually be seen (natural != target).
module a2sub (output logic [3:0] po_nar, output logic [9:0] po_wide);
  localparam int TW = 6;
  logic [3:0] mb_nar;      // module body, narrower than natural 6
  logic [9:0] mb_wide;     // module body, wider   than natural 6
  logic [5:0] mb_exact;    // module body, exactly natural 6
  logic [3:0] mb_mb;       // module body, natural 12 ({6{2'b10}})
  logic       sig;
  logic [7:0] mb_sel;      // a SELECT Lhs
  if (TW > 0) begin : gen_b
    logic [3:0] gl_nar;    // GEN-LOCAL, narrower than natural 6
    logic [9:0] gl_wide;   // GEN-LOCAL, wider   than natural 6
    // --- Lhs in the MODULE BODY (the head's shape) ---
    assign mb_nar   = {TW{1'b1}};      // B1  natural 6 -> target 4
    assign mb_wide  = {TW{1'b1}};      // B2  natural 6 -> target 10
    assign mb_exact = {TW{1'b1}};      // B3  natural 6 == target 6
    assign mb_mb    = {TW{2'b10}};     // B4  natural 12 -> target 4
    assign po_nar   = {TW{1'b1}};      // B5  a module PORT, target 4
    assign po_wide  = {TW{1'b1}};      // B6  a module PORT, target 10
    assign mb_sel[3:0] = {TW{1'b1}};   // B7  a part-select Lhs (no bind)
    // --- Lhs GEN-LOCAL (bindVariable must fail: natural survives) ---
    assign gl_nar   = {TW{1'b1}};      // B8  natural 6, gen-local target 4
    assign gl_wide  = {TW{1'b1}};      // B9  natural 6, gen-local target 10
    // --- negative controls ---
    assign sig      = 1'b0;            // B10 plain literal
  end
endmodule

module a2;
  logic [3:0] t_nar;
  logic [9:0] t_wide;
  a2sub u0 (.po_nar(t_nar), .po_wide(t_wide));   // ONE child instance
  a2sub u1 ();                                    // a SECOND instance (same defn)
  // a gen scope nested TWO deep, Lhs two module bodies out
  localparam int QW = 7;
  logic [3:0] q_nar;
  for (genvar gi = 0; gi < 2; gi++) begin : gen_o
    if (QW > 0) begin : gen_in
      assign q_nar = {QW{1'b1}};                  // B11 natural 7 -> target 4,
    end                                           //     TWO gen scopes deep
  end
endmodule
