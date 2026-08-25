// r10v86 va4 — THE § valueRangeImplicitSigning86 WIDENING, stressed.  Every
// declaration shape whose TYPE SYNTAX is implicit, in the module body, in the
// HEADER (not overridden), in a gen-if and in a gen-for; several widths; read
// BOTH through a foldable `+` and BARE through a `^` carrier golden never
// folds (so the leaf itself is visible).  GOLDEN = Surelog.
module v86_sgn #(parameter int AddrW = 17,
                 parameter signed [7:0]  HS8 = 8'sd3,
                 parameter signed        HSB = 5,
                 parameter signed [31:0] HS32 = 32'sd7,
                 parameter unsigned [7:0] HU8 = 8'd9,
                 parameter               HIM = 11) ();
  localparam signed [7:0]  B_S8  = 8'sd13;
  localparam signed [15:0] B_S16 = 16'sd14;
  localparam signed [31:0] B_S32 = 32'sd15;
  localparam signed [0:0]  B_S1  = 1'sb1;
  localparam signed [3:0]  B_S4  = 4'sd5;
  localparam signed        B_SB  = 16;
  localparam unsigned [7:0] B_U8 = 8'd17;
  localparam unsigned      B_UB  = 18;
  localparam               B_IMP = 19;
  localparam signed [7:0] B_SNEG = -8'sd6;

  // FOLDABLE (`+`) — the subtree fold reads the leaf
  localparam logic[AddrW-1:0] a_s8  = ~(('h1 << (B_S8  + 1)) - 1'b1);
  localparam logic[AddrW-1:0] a_s16 = ~(('h1 << (B_S16 + 1)) - 1'b1);
  localparam logic[AddrW-1:0] a_s32 = ~(('h1 << (B_S32 + 1)) - 1'b1);
  localparam logic[AddrW-1:0] a_s1  = ~(('h1 << (B_S1  + 3)) - 1'b1);
  localparam logic[AddrW-1:0] a_s4  = ~(('h1 << (B_S4  + 1)) - 1'b1);
  localparam logic[AddrW-1:0] a_sb  = ~(('h1 << (B_SB  + 1)) - 1'b1);
  localparam logic[AddrW-1:0] a_u8  = ~(('h1 << (B_U8  + 1)) - 1'b1);
  localparam logic[AddrW-1:0] a_ub  = ~(('h1 << (B_UB  + 1)) - 1'b1);
  localparam logic[AddrW-1:0] a_imp = ~(('h1 << (B_IMP + 1)) - 1'b1);
  localparam logic[AddrW-1:0] a_sng = ~(('h1 << (B_SNEG + 20)) - 1'b1);
  localparam logic[AddrW-1:0] a_hs8 = ~(('h1 << (HS8  + 1)) - 1'b1);
  localparam logic[AddrW-1:0] a_hsb = ~(('h1 << (HSB  + 1)) - 1'b1);
  localparam logic[AddrW-1:0] a_h32 = ~(('h1 << (HS32 + 1)) - 1'b1);
  localparam logic[AddrW-1:0] a_hu8 = ~(('h1 << (HU8  + 1)) - 1'b1);
  localparam logic[AddrW-1:0] a_him = ~(('h1 << (HIM  + 1)) - 1'b1);

  // BARE through a `^` carrier — golden keeps the operation, the leaf shows
  localparam logic[AddrW-1:0] z_s8  = ~(('h1 << (B_S8  ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] z_s16 = ~(('h1 << (B_S16 ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] z_s32 = ~(('h1 << (B_S32 ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] z_s1  = ~(('h1 << (B_S1  ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] z_s4  = ~(('h1 << (B_S4  ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] z_sb  = ~(('h1 << (B_SB  ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] z_u8  = ~(('h1 << (B_U8  ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] z_ub  = ~(('h1 << (B_UB  ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] z_imp = ~(('h1 << (B_IMP ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] z_hs8 = ~(('h1 << (HS8   ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] z_hsb = ~(('h1 << (HSB   ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] z_h32 = ~(('h1 << (HS32  ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] z_hu8 = ~(('h1 << (HU8   ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] z_him = ~(('h1 << (HIM   ^ 1)) - 1'b1);
  // unary `~` over the implicit-signed leaves: the SIZE comes from the
  // typespec when one is present, so the widening changes the fold WIDTH
  localparam logic[AddrW-1:0] n_s8  = ~(('h1 << (~B_S8))  - 1'b1);
  localparam logic[AddrW-1:0] n_sb  = ~(('h1 << (~B_SB))  - 1'b1);
  localparam logic[AddrW-1:0] n_u8  = ~(('h1 << (~B_U8))  - 1'b1);
  localparam logic[AddrW-1:0] n_imp = ~(('h1 << (~B_IMP)) - 1'b1);
  localparam logic[AddrW-1:0] n_hs8 = ~(('h1 << (~HS8))   - 1'b1);

  if (1) begin : gi
    localparam signed [7:0] G_S8 = 8'sd21;
    localparam logic[AddrW-1:0] g_s8 = ~(('h1 << (G_S8 + 1)) - 1'b1);
    localparam logic[AddrW-1:0] g_x8 = ~(('h1 << (G_S8 ^ 1)) - 1'b1);
  end
  for (genvar gk = 0; gk < 2; gk++) begin : gf
    localparam signed [7:0] F_S8 = 8'sd22;
    localparam logic[AddrW-1:0] f_s8 = ~(('h1 << (F_S8 + gk)) - 1'b1);
    localparam logic[AddrW-1:0] f_x8 = ~(('h1 << (F_S8 ^ 1)) - 1'b1);
  end
endmodule

module top86_v4 ();
  v86_sgn #(.AddrW(17)) i0 ();
  v86_sgn #(.AddrW(18)) i1 ();
endmodule
