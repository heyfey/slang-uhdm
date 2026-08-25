// r10earl86 g4 — THE NEGATIVE CONTROLS.  Every row here MUST stay exactly as
// the pristine binary emits it: the law must not reach a tree that does not
// bail, an operator Surelog's reducer has no arm for, an operand it cannot
// value, or a DEF listing.  GOLDEN = Surelog.
module m86_neg #(parameter int AddrW = 17) ();
  localparam int P = 8;
  localparam int W = 5;
  localparam int Z = 0;
  logic [7:0] sig;

  // --- NO BAIL AT ALL: golden folds the WHOLE init; we already do too ------
  localparam logic[AddrW-1:0] n_ful = ~((32'h1 << (P + W)) - 1'b1);
  localparam logic[AddrW-1:0] n_dec = ~(((1) << (P + W)) - 1'b1);
  localparam logic[AddrW-1:0] n_pln = (P + W) * 2;

  // --- BAILS, but the SUBTREE has NO arm in reduceExpr ---------------------
  localparam logic[AddrW-1:0] n_xor = ~(('h1 << (P ^ W)) - 1'b1);
  localparam logic[AddrW-1:0] n_xnr = ~(('h1 << (P ~^ W)) - 1'b1);

  // --- BAILS, and the SUBTREE ITSELF bails (a nested unsized shift) --------
  localparam logic[AddrW-1:0] n_nsh = ~(('h1 << ('h1 << W)) - 1'b1);
  localparam logic[AddrW-1:0] n_nin = ~(('h1 << (('h1 << W) + P)) - 1'b1);

  // --- BAILS, and the SUBTREE names a NON-PARAMETER ------------------------
  localparam logic[AddrW-1:0] n_sig = ~(('h1 << ($bits(sig) + W)) - 1'b1);

  // --- DIVIDE / MODULO BY ZERO --------------------------------------------
  localparam logic[AddrW-1:0] n_dv0 = ~(('h1 << (P / Z)) - 1'b1);
  localparam logic[AddrW-1:0] n_md0 = ~(('h1 << (P % Z)) - 1'b1);

  // --- A CONCAT / REPLICATION SUBTREE (bit assembly, not a value arm) -----
  localparam logic[AddrW-1:0] n_cat = ~(('h1 << {2'b01, 2'b10}) - 1'b1);
  localparam logic[AddrW-1:0] n_rpl = ~(('h1 << {2{2'b01}}) - 1'b1);

  // --- AN UNBASED-UNSIZED literal in the subtree ---------------------------
  localparam logic[AddrW-1:0] n_unb = ~(('h1 << ('1 + P)) - 1'b1);
  localparam logic[AddrW-1:0] n_unx = ~(('h1 << ('x + P)) - 1'b1);
endmodule

module top86_neg ();
  m86_neg #(.AddrW(17)) i0 ();
endmodule
