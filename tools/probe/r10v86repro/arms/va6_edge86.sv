// r10v86 va6 — EDGES of the transcribed encoder: size(-1) propagation through
// non-shift arms, comparisons against unsized operands, large shift counts,
// negative operands through the unsigned readers, and enum / typedef leaves.
// GOLDEN = Surelog.
typedef enum int { E0 = 3, E1 = 6 } v86_e;
module v86_edg #(parameter int AddrW = 24) ();
  localparam int P = 8;
  localparam int W = 5;
  localparam int N = -3;
  localparam v86_e EV = E1;
  localparam logic [7:0] LW = 8'd3;

  // an ADD of two UNSIZED BASED literals: max(sz) is -1, which trips rule (1)
  localparam logic[AddrW-1:0] e_uad = ~(('h1 << ('h2 + 'h3)) - 1'b1);
  localparam logic[AddrW-1:0] e_uax = ~(('h1 << ('h2 + P)) - 1'b1);
  // a nested shift whose BASE is a folded unsized add -> the INNER shift bails
  localparam logic[AddrW-1:0] e_ibl = ~(('h1 << (('h2 + 'h3) << W)) - 1'b1);
  // a comparison whose operand is unsized (reduceCompOp resizes in place)
  localparam logic[AddrW-1:0] e_cmp = ~(('h1 << (('h2 > P) + 3)) - 1'b1);
  localparam logic[AddrW-1:0] e_cm2 = ~(('h1 << ((P > 'h2) + 3)) - 1'b1);
  // NEGATIVE operands through the readers
  localparam logic[AddrW-1:0] e_ngs = ~(('h1 << (N + 20)) - 1'b1);
  localparam logic[AddrW-1:0] e_ng2 = ~(('h1 << (N * N)) - 1'b1);
  localparam logic[AddrW-1:0] e_ng3 = ~(('h1 << (N - N)) - 1'b1);
  localparam logic[AddrW-1:0] e_ng4 = ~(('h1 << ((-N) + 2)) - 1'b1);
  localparam logic[AddrW-1:0] e_ng5 = ~(('h1 << ((N < 0) + 4)) - 1'b1);
  localparam logic[AddrW-1:0] e_ng6 = ~(('h1 << ((N & 7) + 1)) - 1'b1);
  // LARGE shift counts inside a foldable subtree
  localparam logic[AddrW-1:0] e_big = ~(('h1 << ((P << 6) >> 6)) - 1'b1);
  localparam logic[AddrW-1:0] e_bg2 = ~(('h1 << ((1 << 30) >> 27)) - 1'b1);
  // ENUM leaf and a typedef'd leaf
  localparam logic[AddrW-1:0] e_enu = ~(('h1 << (EV + 1)) - 1'b1);
  localparam logic[AddrW-1:0] e_en2 = ~(('h1 << (E0 + W)) - 1'b1);
  // power / division edges
  localparam logic[AddrW-1:0] e_pw0 = ~(('h1 << (P ** 0)) - 1'b1);
  localparam logic[AddrW-1:0] e_pw1 = ~(('h1 << (2 ** 4)) - 1'b1);
  localparam logic[AddrW-1:0] e_dvn = ~(('h1 << ((P / N) + 12)) - 1'b1);
  localparam logic[AddrW-1:0] e_mdn = ~(('h1 << ((P % 3) + 4)) - 1'b1);
  // a unary reduction over a WIDE operand (the transcribed loop bounds)
  localparam logic[AddrW-1:0] e_rw1 = ~(('h1 << ((&LW) + 4)) - 1'b1);
  localparam logic[AddrW-1:0] e_rw2 = ~(('h1 << ((~&LW) + 4)) - 1'b1);
  localparam logic[AddrW-1:0] e_rw3 = ~(('h1 << ((|LW) + 4)) - 1'b1);
  localparam logic[AddrW-1:0] e_rw4 = ~(('h1 << ((~|LW) + 4)) - 1'b1);
  localparam logic[AddrW-1:0] e_rw5 = ~(('h1 << ((^LW) + 4)) - 1'b1);
  localparam logic[AddrW-1:0] e_rw6 = ~(('h1 << ((~^LW) + 4)) - 1'b1);
  // unsized OCTAL / BINARY / DECIMAL based literals
  localparam logic[AddrW-1:0] e_oct = ~(('o1 << (P + W)) - 1'b1);
  localparam logic[AddrW-1:0] e_bin = ~(('b1 << (P + W)) - 1'b1);
  localparam logic[AddrW-1:0] e_dec = ~(('d1 << (P + W)) - 1'b1);
  localparam logic[AddrW-1:0] e_shx = ~(('sh1 << (P + W)) - 1'b1);
endmodule

module top86_v6 ();
  v86_edg #(.AddrW(24)) i0 ();
endmodule
