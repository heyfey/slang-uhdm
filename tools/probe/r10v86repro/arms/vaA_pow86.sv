// r10v86 vaA — the remaining encoder corners: `**` through the DOUBLE that
// `std::pow<int64_t>` actually goes through (the pass transcribes it with
// `powl`, a LONG DOUBLE with an 11-bit-wider mantissa), the arithmetic shifts
// `<<<` / `>>>` (Surelog folds BOTH with a LOGICAL `>>` on uint64_t), and
// signed `/` `%` with a negative divisor.  GOLDEN = Surelog.
module v86_pw #(parameter int AddrW = 26) ();
  localparam int P = 8;
  localparam int W = 5;

  // ** results that do NOT fit a double's 53-bit mantissa exactly
  localparam logic[AddrW-1:0] p_720 = ~(('h1 << ((7 ** 20) >> 53)) - 1'b1);
  localparam logic[AddrW-1:0] p_319 = ~(('h1 << ((3 ** 39) >> 58)) - 1'b1);
  localparam logic[AddrW-1:0] p_524 = ~(('h1 << ((5 ** 25) >> 55)) - 1'b1);
  localparam logic[AddrW-1:0] p_260 = ~(('h1 << ((2 ** 60) >> 57)) - 1'b1);
  localparam logic[AddrW-1:0] p_ovf = ~(('h1 << ((3 ** 41) >> 60)) - 1'b1);
  localparam logic[AddrW-1:0] p_neg = ~(('h1 << (((-3) ** 3) + 30)) - 1'b1);
  localparam logic[AddrW-1:0] p_sml = ~(('h1 << ((3 ** 3) - 24)) - 1'b1);

  // arithmetic shifts
  localparam logic[AddrW-1:0] p_als = ~(('h1 << ((P <<< 1) + 1)) - 1'b1);
  localparam logic[AddrW-1:0] p_ars = ~(('h1 << ((P >>> 1) + 1)) - 1'b1);
  localparam logic[AddrW-1:0] p_arn = ~(('h1 << (((-64) >>> 3) + 12)) - 1'b1);
  localparam logic[AddrW-1:0] p_arm = ~(('h1 << (((-64) >> 3) + 12)) - 1'b1);

  // signed / and % with a negative divisor
  localparam logic[AddrW-1:0] p_dvn = ~(('h1 << ((9 / (-4)) + 6)) - 1'b1);
  localparam logic[AddrW-1:0] p_mdn = ~(('h1 << ((9 % (-4)) + 5)) - 1'b1);
  localparam logic[AddrW-1:0] p_dnn = ~(('h1 << (((-9) / (-4)) + 4)) - 1'b1);
endmodule

module top86_vA ();
  v86_pw #(.AddrW(26)) i0 ();
endmodule
