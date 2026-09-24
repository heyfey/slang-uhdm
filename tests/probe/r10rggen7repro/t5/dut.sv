// r10rggen7 t5: does a DEF-view gen-if CONDITION bind an enum_const?
// Two siblings in ONE module: a BARE if-generate (no generate/endgenerate
// keywords, the GenIfInside shape, which golden BINDS) and one wrapped in an
// explicit `generate ... endgenerate` region (the Rggen rggen_bit_field:221
// shape).  Plus a module-level localparam reading the same constant as the
// always-binds control.
package t5_pkg;
  typedef enum int { T5_NONE = 0, T5_SET = 1 } t5_e;
endpackage

module t5
  import t5_pkg::*;
#(
  parameter t5_e ACTION = T5_NONE
)(
  output int o_bare,
  output int o_gen,
  output int o_lp
);
  localparam bit READABLE = (ACTION != T5_NONE);

  if (ACTION != T5_NONE) begin : g_bare
    assign o_bare = 1;
  end else begin : g_bare_else
    assign o_bare = 0;
  end

  generate if (ACTION != T5_NONE) begin : g_wrapped
    assign o_gen = 1;
  end else begin : g_wrapped_else
    assign o_gen = 0;
  end endgenerate

  assign o_lp = int'(READABLE);
endmodule
