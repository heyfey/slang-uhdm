// r10v86 va3 — POSITIONS: the shift AMOUNT, the shift BASE, a SUBTRACT
// operand, BOTH operands of the bailing op, and the root itself.
// GOLDEN = Surelog.  MEASUREMENT ONLY.
module v86_pos #(parameter int AddrW = 20) ();
  localparam int P = 8;
  localparam int W = 5;
  localparam int C = 2;

  // amount
  localparam logic[AddrW-1:0] y_amt = ~(('h1 << (P + W)) - 1'b1);
  // BASE is a subtree, the unsized literal is the AMOUNT
  localparam logic[AddrW-1:0] y_bas = ~(((P + W) << 'h1) - 1'b1);
  // BASE is a subtree that itself carries the unsized literal
  localparam logic[AddrW-1:0] y_bs2 = ~((('h1 + P) << W) - 1'b1);
  // the SUBTRACT operand is a subtree
  localparam logic[AddrW-1:0] y_sub = ~(('h1 << P) - (W + C));
  // BOTH operands of the outer subtract are subtrees
  localparam logic[AddrW-1:0] y_bth = ~((('h1 << (P + W)) - (W * C)));
  // BOTH operands of a NON-bailing inner shift, with the unsized literal above
  localparam logic[AddrW-1:0] y_ns  = (((P + W) << (W + C)) - 'h1);
  // the ROOT is the bailing shift itself
  localparam logic[AddrW-1:0] y_rt  = ('h1 << (P + W));
  // the ROOT is a subtract whose left is the bailing shift
  localparam logic[AddrW-1:0] y_rs  = (('h1 << (P + W)) - 1'b1);
  // a subtree on EACH side of a top-level OR
  localparam logic[AddrW-1:0] y_or  = (('h1 << (P + W)) | ((P * C) + 1));
  // a subtree three levels below the bail
  localparam logic[AddrW-1:0] y_dp  = ~((('h1 << ((P + W) * C)) - 1'b1) + (W - C));
  // the unsized literal in a SIBLING branch entirely
  localparam logic[AddrW-1:0] y_sib = ((P + W) * C) + ('h1 << W);
  // a comparison whose operand is a subtree
  localparam logic[AddrW-1:0] y_cmp = ~(('h1 << (((P + W) > C) + 3)) - 1'b1);
endmodule

module top86_v3 ();
  v86_pos #(.AddrW(20)) i0 ();
  v86_pos #(.AddrW(21)) i1 ();
endmodule
