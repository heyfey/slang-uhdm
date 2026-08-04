// r10rggen7 t7: UNBASED-UNSIZED literal ('0 / '1) as a cont_assign Rhs, in
// the DEF and ELAB views, at 1-bit and 4-bit LHS widths, module level and
// inside a generate scope.  Rggen rggen_bit_field:218
// `assign sw_write_done = '0;` is the elab gen-scope 1-bit case (728 gen-tree
// vectors): golden BIN:0 size 1, we leave size -1 (unsized).
module t7 #(parameter bit EN = 0)(
  output logic       o_one0,
  output logic       o_one1,
  output logic [3:0] o_four0,
  output logic [3:0] o_four1,
  output logic       o_gen_one0,
  output logic [3:0] o_gen_four1,
  output logic [1:0] o_gen_sel
);
  assign o_one0  = '0;
  assign o_one1  = '1;
  assign o_four0 = '0;
  assign o_four1 = '1;

  generate if (EN) begin : g_on
    assign o_gen_one0  = '1;
    assign o_gen_four1 = '0;
    assign o_gen_sel[1] = '1;
  end
  else begin : g_off
    assign o_gen_one0  = '0;
    assign o_gen_four1 = '1;
    // BIT-SELECT LHS: no assignment-context width, so the literal stays
    // UNSIZED (-1) even in the elab view — Rggen rggen_bit_field:232
    // `assign trigger[0] = '0;`, the discriminator against :218's whole-ref
    // LHS.
    assign o_gen_sel[0] = '0;
  end endgenerate
endmodule

module t7_top;
  logic       a, b, e;
  logic [3:0] c, d, f;
  logic [1:0] g;
  t7 #(1'b0) u_t7 (.o_one0(a), .o_one1(b), .o_four0(c), .o_four1(d),
                   .o_gen_one0(e), .o_gen_four1(f), .o_gen_sel(g));
endmodule
