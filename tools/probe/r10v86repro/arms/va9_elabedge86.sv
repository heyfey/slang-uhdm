// r10v86 va9 — THE --elabuhdm VIEW is where PRISTINE is RIGHT: `UhdmAdjuster`
// reduces the kept tree with UHDM's OWN `ExprEval`, so any transcription error
// in the pass's encoder shows up there as RIGHT->WRONG.  These rows drive the
// encoder into its corners.  GOLDEN = Surelog.
module v86_ee #(parameter int AddrW = 24, parameter int OVW = 3) ();
  localparam int P = 8;
  localparam int W = 5;
  localparam int N = -3;

  // --- comparisons with a TOP-BIT-SET unsigned read (reduceCompOp reads
  //     UNSIGNED into an int64_t and compares SIGNED) -----------------------
  localparam logic[AddrW-1:0] e_gt  = ~(('h1 << (((1 << 63) > 5) + 3)) - 1'b1);
  localparam logic[AddrW-1:0] e_ge  = ~(('h1 << (((1 << 63) >= 5) + 3)) - 1'b1);
  localparam logic[AddrW-1:0] e_lt  = ~(('h1 << (((1 << 63) < 5) + 3)) - 1'b1);
  localparam logic[AddrW-1:0] e_le  = ~(('h1 << (((1 << 63) <= 5) + 3)) - 1'b1);
  localparam logic[AddrW-1:0] e_eq  = ~(('h1 << (((1 << 63) == 5) + 3)) - 1'b1);
  localparam logic[AddrW-1:0] e_ne  = ~(('h1 << (((1 << 63) != 5) + 3)) - 1'b1);
  localparam logic[AddrW-1:0] e_rv  = ~(('h1 << ((5 < (1 << 63)) + 3)) - 1'b1);
  localparam logic[AddrW-1:0] e_bb  = ~(('h1 << (((1 << 63) > (1 << 62)) + 3)) - 1'b1);
  // a top-bit-set value from `~` at width 64
  localparam logic[AddrW-1:0] e_ng  = ~(('h1 << ((((1 << 40) - 1) > 5) + 3)) - 1'b1);

  // --- SHIFT COUNTS at and beyond the word ---------------------------------
  localparam logic[AddrW-1:0] e_s70 = ~(('h1 << ((P << 70) + 3)) - 1'b1);
  localparam logic[AddrW-1:0] e_r70 = ~(('h1 << ((P >> 70) + 3)) - 1'b1);
  localparam logic[AddrW-1:0] e_s64 = ~(('h1 << ((P << 64) + 3)) - 1'b1);
  localparam logic[AddrW-1:0] e_s63 = ~(('h1 << ((1 << 63) >> 60)) - 1'b1);

  // --- bit / logical ops over top-bit-set operands -------------------------
  localparam logic[AddrW-1:0] e_and = ~(('h1 << (((1 << 63) & 7) + 3)) - 1'b1);
  localparam logic[AddrW-1:0] e_ior = ~(('h1 << ((((1 << 63) | 7) >> 60)) ) - 1'b1);
  localparam logic[AddrW-1:0] e_lan = ~(('h1 << (((1 << 63) && 7) + 3)) - 1'b1);
  localparam logic[AddrW-1:0] e_lor = ~(('h1 << (((1 << 63) || 0) + 3)) - 1'b1);
  localparam logic[AddrW-1:0] e_not = ~(('h1 << ((!(1 << 63)) + 3)) - 1'b1);

  // --- arithmetic over top-bit-set operands --------------------------------
  localparam logic[AddrW-1:0] e_sub = ~(('h1 << (((1 << 63) - (1 << 63)) + 3)) - 1'b1);
  localparam logic[AddrW-1:0] e_add = ~(('h1 << ((((1 << 63) + (1 << 63)) >> 60) + 3)) - 1'b1);
  localparam logic[AddrW-1:0] e_mnu = ~(('h1 << (((-(1 << 62)) >> 60) + 3)) - 1'b1);

  // --- power / modulo corners ---------------------------------------------
  localparam logic[AddrW-1:0] e_pw  = ~(('h1 << ((3 ** 3) - 24)) - 1'b1);
  localparam logic[AddrW-1:0] e_pwn = ~(('h1 << ((2 ** N) + 4)) - 1'b1);
  localparam logic[AddrW-1:0] e_pwb = ~(('h1 << ((2 ** 40) >> 37)) - 1'b1);
  localparam logic[AddrW-1:0] e_mdn = ~(('h1 << (((-9) % 4) + 5)) - 1'b1);
  localparam logic[AddrW-1:0] e_dvn = ~(('h1 << (((-9) / 4) + 5)) - 1'b1);
endmodule

module top86_v9 ();
  v86_ee #(.AddrW(24), .OVW(3)) i0 ();
endmodule
