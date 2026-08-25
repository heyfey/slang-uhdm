// r10v86 va7 — THE COMPARISON READER'S SIGNEDNESS.  `ExprEval::reduceCompOp`
// (UHDM/templates/ExprEval.cpp:1667-1668) reads both operands with
// `get_uvalue` INTO `int64_t` and then compares them SIGNED; the pass's
// transcription compares them UNSIGNED.  These rows put a value with the top
// bit set on one side.  GOLDEN = Surelog.
module v86_scmp #(parameter int AddrW = 24, parameter int OVW = 3) ();
  localparam int P = 8;
  localparam int W = 5;

  // (1 << 63) folds to UINT:9223372036854775808 at size 64 -> top bit set
  localparam logic[AddrW-1:0] s_gt  = ~(('h1 << (((1 << 63) > 5) + 3)) - 1'b1);
  localparam logic[AddrW-1:0] s_lt  = ~(('h1 << (((1 << 63) < 5) + 3)) - 1'b1);
  localparam logic[AddrW-1:0] s_ge  = ~(('h1 << (((1 << 63) >= 5) + 3)) - 1'b1);
  localparam logic[AddrW-1:0] s_le  = ~(('h1 << (((1 << 63) <= 5) + 3)) - 1'b1);
  localparam logic[AddrW-1:0] s_eq  = ~(('h1 << (((1 << 63) == 5) + 3)) - 1'b1);
  // ~ of a 64-bit-sized OVERRIDDEN leaf also yields a top-bit-set UINT
  localparam logic[AddrW-1:0] s_ng  = ~(('h1 << (((~OVW) > 5) + 3)) - 1'b1);
  // and the same value on the RIGHT of the comparison
  localparam logic[AddrW-1:0] s_rgt = ~(('h1 << ((5 > (1 << 63)) + 3)) - 1'b1);
  // a plain, in-range comparison as the control
  localparam logic[AddrW-1:0] s_ctl = ~(('h1 << (((P + W) > 5) + 3)) - 1'b1);
endmodule

module top86_v7 ();
  v86_scmp #(.AddrW(24), .OVW(3)) i0 ();
endmodule
