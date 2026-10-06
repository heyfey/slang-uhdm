// § topNestedArrElemTopTwin269 (Earlgrey flash_ctrl_reg_top reduced: one prim_subreg, the real package)
module flash_ctrl_reg_top (
  input clk_i,
  input rst_ni,
  output flash_ctrl_reg_pkg::flash_ctrl_reg2hw_t reg2hw,
  input  flash_ctrl_reg_pkg::flash_ctrl_hw2reg_t hw2reg
);
  import flash_ctrl_reg_pkg::* ;
  logic mp_region_cfg0_en0_qs;
  logic mp_region_cfg0_en0_wd;
  logic mp_region_cfg0_en0_we;
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_mp_region_cfg0_en0 (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),
    .we     (mp_region_cfg0_en0_we),
    .wd     (mp_region_cfg0_en0_wd),
    .de     (1'b0),
    .d      ('0  ),
    .qe     (),
    .q      (reg2hw.mp_region_cfg[0].en.q ),
    .qs     (mp_region_cfg0_en0_qs)
  );
endmodule
