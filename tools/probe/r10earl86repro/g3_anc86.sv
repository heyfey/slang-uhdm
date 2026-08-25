// r10earl86 g3 — THE BAILING ANCESTOR x HOME x INSTANCE-COUNT grid.
// Which enclosing shape keeps the tree, and where the kept tree lives.
// GOLDEN = Surelog.  MEASUREMENT ONLY.
package q86c_pkg;
  parameter int PKP = 8;
  parameter int PKW = 5;
  // A PACKAGE home: the law must not touch it (packages are DEF-view).
  localparam logic [16:0] pk_add = ~(('h1 << (PKP + PKW)) - 1'b1);
  localparam logic [16:0] pk_mul = ~(('h1 << (PKP * PKW)) - 1'b1);
endpackage

module m86_anc #(parameter int AddrW = 17, parameter int SEL = 1) ();
  localparam int P = 8;
  localparam int W = 5;

  // --- ANCESTOR A: the SHIFT AMOUNT (the Earlgrey head's own position) -----
  localparam logic[AddrW-1:0] a_amt = ~(('h1 << (P + W)) - 1'b1);
  // --- ANCESTOR B: the shift is bare, no outer unary ------------------------
  localparam logic[AddrW-1:0] a_shf = 'h1 << (P + W);
  // --- ANCESTOR C: a SIBLING of the bailing shift --------------------------
  localparam logic[AddrW-1:0] a_sib = ('h1 << W) + (P * W);
  // --- ANCESTOR D: under a unary ~ only ------------------------------------
  localparam logic[AddrW-1:0] a_neg = ~('h1 << (P + W));
  // --- ANCESTOR E: a CONCAT carrying the bailing shift ---------------------
  localparam logic[AddrW-1:0] a_cat = {('h1 << W), (P + W)};
  // --- ANCESTOR F: a REPLICATION -------------------------------------------
  localparam logic[AddrW-1:0] a_rep = {2{('h1 << W) + (P - W)}};
  // --- ANCESTOR G: a TERNARY whose UNTAKEN arm bails -----------------------
  localparam logic[AddrW-1:0] a_tun = (SEL != 0) ? (P + W) : ('h1 << (P * W));
  // --- ANCESTOR H: a TERNARY whose TAKEN arm bails -------------------------
  localparam logic[AddrW-1:0] a_ttk = (SEL == 0) ? (P + W) : ('h1 << (P * W));
  // --- ANCESTOR I: THREE levels between the bail and the foldable subtree --
  localparam logic[AddrW-1:0] a_dp3 = ~((('h1 << (P + W)) - 1'b1) | 17'h3);

  // --- HOME: a GEN-IF scope -------------------------------------------------
  if (1) begin : gi86
    localparam logic[AddrW-1:0] g_add = ~(('h1 << (P + W)) - 1'b1);
    localparam logic[AddrW-1:0] g_mul = ~(('h1 << (P * W)) - 1'b1);
  end
  // --- HOME: a GEN-FOR scope, two iterations --------------------------------
  for (genvar gi = 0; gi < 2; gi++) begin : gf86
    localparam logic[AddrW-1:0] f_add = ~(('h1 << (P + W + gi)) - 1'b1);
  end
endmodule

module top86_anc ();
  // 1-3 INSTANCES of the same definition: the ELAB copies must all move.
  m86_anc #(.AddrW(17), .SEL(1)) i0 ();
  m86_anc #(.AddrW(18), .SEL(1)) i1 ();
  m86_anc #(.AddrW(19), .SEL(0)) i2 ();
endmodule
