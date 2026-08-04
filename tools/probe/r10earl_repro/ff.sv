// r10earl4 ff.sv — § genRefModuleWildcardConn.
// Earlgrey's `PRIM_DEFAULT_IMPL` modules all instantiate their implementation
// child with a BARE `.*` wildcard connection inside a generate block
// (prim_ram_1p 3 heads, prim_ram_2p 3, prim_rom 2, prim_clock_gating 2,
// prim_clock_mux2 1, prim_flash 1, prim_pad_wrapper 1 — "golden ref_module,
// ours <null>": the def-view gen block comes out EMPTY on our side).
// Rows: A `if (1)` gen block, B `if/else` gen arms, C plain module scope.
module fchild (
  input  logic clk_i,
  input  logic rst_ni,
  input  logic a,
  output logic o
);
  assign o = a & clk_i & rst_ni;
endmodule

module ff (
  input  logic clk_i,
  input  logic rst_ni,
  input  logic a,
  output logic o,
  output logic o2,
  output logic o3
);
  // A: constant-true gen block, bare `.*`
  if (1) begin : gen_a
    fchild u_impl_a (
      .*
    );
  end

  // B: if/else gen arms, bare `.*` in each (the prim_clock_gating shape)
  logic o_b;
  if (0) begin : gen_b_x
    fchild u_impl_x (
      .clk_i,
      .rst_ni,
      .a,
      .o (o_b)
    );
  end else begin : gen_b_g
    fchild u_impl_g (
      .clk_i,
      .rst_ni,
      .a,
      .o (o_b)
    );
  end
  assign o2 = o_b;

  // C: plain module scope, bare `.*` (control)
  logic o_c;
  fchild u_flat (
    .*,
    .o (o_c)
  );
  assign o3 = o_c;
endmodule
