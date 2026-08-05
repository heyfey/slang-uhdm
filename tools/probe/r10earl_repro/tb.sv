// r10earl7 witness tb — DEF-VIEW GEN-BLOCK localparam declarations.
// The ta.sv head ADVANCED to `operation '' ibex_alu.sv:712:9 vs <null>`:
//   localparam logic [31:0] SHUFFLE_MASK_L [0:3] =
//       '{32'h00ff_0000, 32'h0f00_0f00, 32'h3030_3030, 32'h4444_4444};
// inside `if (RV32B) begin : g_alu_rvb`.  Golden's module DEF listing gives
// that parameter a Rhs (positional-pattern operation 75), a vpiSize of the
// ELEMENT COUNT, the unpacked dims as its OWN vpiRange and an ELEMENT
// logic_typespec; we emitted it bare with a rangeless int_typespec.
// Deliberately NO module-scope localparam here: a module-scope
// `CTL_MASK[0] ^ CTL_ONE` cont-assign has its own fold difference that masks
// this one.
module tb #(
  parameter bit RVB = 1'b0
) (
  input  logic        clk_i,
  output logic [31:0] z_o
);

  if (RVB) begin : g_rvb                 // NOT-TAKEN branch (the ibex shape)
    localparam logic [31:0] GS_MASK_L [0:3] =
        '{32'h00ff_0000, 32'h0f00_0f00, 32'h3030_3030, 32'h4444_4444};
    localparam logic [31:0] GS_SIZED [4] =
        '{32'h1, 32'h2, 32'h3, 32'h4};
    localparam logic [ 7:0] GS_2D [2][2] =
        '{'{8'h1, 8'h2}, '{8'h3, 8'h4}};
    localparam logic [31:0] GS_ONE = 32'h1;   // scalar control (already right)
    localparam int          GS_N   = 4;       // scalar control (already right)
    localparam              GS_U   = 7;       // untyped control

    logic [31:0] gs_v;
    assign gs_v = GS_MASK_L[0] ^ GS_ONE;
  end : g_rvb

  if (!RVB) begin : g_norvb              // TAKEN branch — same shapes
    localparam logic [31:0] GT_MASK_L [0:3] =
        '{32'h00ff_0000, 32'h0f00_0f00, 32'h3030_3030, 32'h4444_4444};
    localparam logic [31:0] GT_SIZED [4] =
        '{32'h1, 32'h2, 32'h3, 32'h4};
    localparam logic [31:0] GT_ONE = 32'h1;

    logic [31:0] gt_v;
    assign gt_v = GT_MASK_L[0] ^ GT_ONE;
  end : g_norvb

  assign z_o = 32'h0;

endmodule
