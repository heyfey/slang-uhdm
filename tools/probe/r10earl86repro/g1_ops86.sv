// r10earl86 g1 — THE OPERATOR GRID for the sub-expression a bail-kept tree
// keeps.  Every row is `~(('h1 << <SUB>) - 1'b1)` : the SHIFT bails (rule (1),
// § srlgUnsizedBasedShiftBail85) so the whole tree survives, and <SUB> is the
// maximal operand subtree whose own compileExpression level DID reduce.
// GOLDEN = Surelog.  MEASUREMENT ONLY.
package q86_pkg;
  parameter int PKGP = 3;
endpackage

module m86_ops #(parameter int AddrW = 17) ();
  localparam int P = 8;
  localparam int W = 5;
  localparam logic [7:0] LW = 8'd3;
  localparam int Z = 0;
  localparam BARE = 4;

  // --- BINARY OPERATORS, two int-localparam operands -----------------------
  localparam logic[AddrW-1:0] o_add = ~(('h1 << (P + W)) - 1'b1);
  localparam logic[AddrW-1:0] o_sub = ~(('h1 << (P - W)) - 1'b1);
  localparam logic[AddrW-1:0] o_mul = ~(('h1 << (P * W)) - 1'b1);
  localparam logic[AddrW-1:0] o_div = ~(('h1 << (P / W)) - 1'b1);
  localparam logic[AddrW-1:0] o_mod = ~(('h1 << (P % W)) - 1'b1);
  localparam logic[AddrW-1:0] o_shl = ~(('h1 << (P << W)) - 1'b1);
  localparam logic[AddrW-1:0] o_shr = ~(('h1 << (P >> W)) - 1'b1);
  localparam logic[AddrW-1:0] o_and = ~(('h1 << (P & W)) - 1'b1);
  localparam logic[AddrW-1:0] o_or  = ~(('h1 << (P | W)) - 1'b1);
  localparam logic[AddrW-1:0] o_xor = ~(('h1 << (P ^ W)) - 1'b1);
  localparam logic[AddrW-1:0] o_pow = ~(('h1 << (P ** 2)) - 1'b1);
  localparam logic[AddrW-1:0] o_lan = ~(('h1 << (P && W)) - 1'b1);
  localparam logic[AddrW-1:0] o_lor = ~(('h1 << (P || W)) - 1'b1);
  localparam logic[AddrW-1:0] o_lt  = ~(('h1 << (P < W)) - 1'b1);
  localparam logic[AddrW-1:0] o_eq  = ~(('h1 << (P == W)) - 1'b1);

  // --- UNARY ---------------------------------------------------------------
  localparam logic[AddrW-1:0] u_neg = ~(('h1 << (-P)) - 1'b1);
  localparam logic[AddrW-1:0] u_not = ~(('h1 << (!Z)) - 1'b1);
  localparam logic[AddrW-1:0] u_bng = ~(('h1 << (~LW)) - 1'b1);
  localparam logic[AddrW-1:0] u_rnd = ~(('h1 << (&LW)) - 1'b1);
  localparam logic[AddrW-1:0] u_ror = ~(('h1 << (|LW)) - 1'b1);
  localparam logic[AddrW-1:0] u_rxr = ~(('h1 << (^LW)) - 1'b1);

  // --- THREE OPERANDS ------------------------------------------------------
  localparam logic[AddrW-1:0] t_cnd = ~(('h1 << ((P > W) ? P : W)) - 1'b1);
  localparam logic[AddrW-1:0] t_cn2 = ~(('h1 << ((P < W) ? P : W)) - 1'b1);
  localparam logic[AddrW-1:0] t_add = ~(('h1 << (P + W + 1)) - 1'b1);
  localparam logic[AddrW-1:0] t_mix = ~(('h1 << (P + W * 2)) - 1'b1);

  // --- NESTING DEPTH 1..3 --------------------------------------------------
  localparam logic[AddrW-1:0] n_d1 = ~(('h1 << (P + W)) - 1'b1);
  localparam logic[AddrW-1:0] n_d2 = ~(('h1 << ((P + W) * 1)) - 1'b1);
  localparam logic[AddrW-1:0] n_d3 = ~(('h1 << (((P + W) * 1) - 2)) - 1'b1);

  // --- SYS FUNC ------------------------------------------------------------
  localparam logic[AddrW-1:0] s_clg = ~(('h1 << ($clog2(P) + W)) - 1'b1);
endmodule

module top86_ops ();
  m86_ops #(.AddrW(17)) i0 ();
endmodule
