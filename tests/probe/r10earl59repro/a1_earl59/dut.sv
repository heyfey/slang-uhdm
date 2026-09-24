// r10earl59 arm A1 — the LHS of a gen-scope cont_assign that names a signal
// declared in the ENCLOSING MODULE (not in any generate scope).
//
// The Earlgrey R0 shape (prim_fifo_sync.sv:145):
//   module ANSI `output [W-1:0] rdata` (a NET), assigned from inside a NESTED
//   if-generate:  `assign rdata = empty ? 'b0 : rdata_int;`
// Golden binds that Lhs ref_obj's vpiActual to the MODULE-level logic_net; we
// leave it null.  Every row here varies ONE thing so the law's fences are
// measured, not guessed.
//
// row naming:  <target-kind>_<gen-nesting>_<rhs-shape>
//   target-kind: pn = ANSI output PORT net        pv = ANSI `output logic` var
//                mn = module-level `wire`          mv = module-level `logic` var
//                mw = module-level `logic` net via `wire logic`
//   gen-nesting: d1 = flat if-gen   d2 = if-gen inside if-gen
//                fg = for-generate body   ug = UNNAMED begin/end gen block
//   rhs-shape:   tern = ternary operation (the Earlgrey shape)
//                bare = whole bare ref     op = binary operation
//                lit  = literal constant   sel = bit-select

module a1 (
  input               clk,
  input        [3:0]  din,
  output       [3:0]  pn_d1_tern,   // PORT NET, flat if-gen, ternary
  output       [3:0]  pn_d2_tern,   // PORT NET, NESTED if-gen, ternary  <== EARLGREY
  output       [3:0]  pn_d2_bare,
  output       [3:0]  pn_d2_op,
  output       [3:0]  pn_d2_lit,
  output       [3:0]  pn_d2_sel,
  output       [3:0]  pn_fg_tern,
  output       [3:0]  pn_ug_tern,
  output logic [3:0]  pv_d2_tern,   // PORT VAR (output logic)
  output       [3:0]  pn_d1_bare
);

  wire  [3:0] mn_src;
  wire  [3:0] mn_d2_tern;          // module-level WIRE net
  wire  [3:0] mn_d1_tern;
  logic [3:0] mv_d2_tern;          // module-level LOGIC var
  logic [3:0] mv_d1_tern;
  wire  [3:0] mn_d2_bare;
  logic       mempty;

  assign mn_src = din;
  assign mempty = din[0];

  if (1) begin : g_a
    wire [3:0] loc_a;
    assign loc_a = mn_src;
    assign pn_d1_tern = mempty ? 4'b0 : loc_a;
    assign pn_d1_bare = loc_a;
    assign mn_d1_tern = mempty ? 4'b0 : loc_a;
    assign mv_d1_tern = mempty ? 4'b0 : loc_a;

    if (1) begin : g_b
      wire [3:0] loc_b;
      assign loc_b = mn_src;
      assign pn_d2_tern = mempty ? 4'b0 : loc_b;   // <== THE EARLGREY ROW
      assign pn_d2_bare = loc_b;
      assign pn_d2_op   = loc_b | mn_src;
      assign pn_d2_lit  = 4'b0;
      assign pn_d2_sel  = {3'b0, loc_b[1]};
      assign pv_d2_tern = mempty ? 4'b0 : loc_b;
      assign mn_d2_tern = mempty ? 4'b0 : loc_b;
      assign mv_d2_tern = mempty ? 4'b0 : loc_b;
      assign mn_d2_bare = loc_b;
    end
  end

  genvar gi;
  for (gi = 0; gi < 1; gi = gi + 1) begin : g_f
    wire [3:0] loc_f;
    assign loc_f = mn_src;
    assign pn_fg_tern = mempty ? 4'b0 : loc_f;
  end

  if (1) begin
    wire [3:0] loc_u;
    assign loc_u = mn_src;
    assign pn_ug_tern = mempty ? 4'b0 : loc_u;
  end

endmodule
