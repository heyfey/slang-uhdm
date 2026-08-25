// r10v86 va8 — STRUCTURAL homes the earlier arms do not reach: a module
// instantiated INSIDE a gen-for and a gen-if, three hierarchy levels, a
// never-instantiated module (DEF only), nested generate scopes, and a module
// with two ELAB copies whose subtree values must NOT leak between them
// (the walk MUTATES the operand vector in place).  GOLDEN = Surelog.
module v86_leaf #(parameter int K = 3, parameter int AddrW = 18) ();
  localparam int W = 5;
  localparam logic[AddrW-1:0] l_add = ~(('h1 << (K + W)) - 1'b1);
  localparam logic[AddrW-1:0] l_mul = ~(('h1 << (K * W)) - 1'b1);
  localparam logic[AddrW-1:0] l_bar = ~(('h1 << K) - 1'b1);
endmodule

module v86_mid #(parameter int M = 2) ();
  v86_leaf #(.K(M + 1), .AddrW(18)) a0 ();
  v86_leaf #(.K(M + 4), .AddrW(19)) a1 ();
  for (genvar gg = 0; gg < 3; gg++) begin : gl
    v86_leaf #(.K(gg + 2), .AddrW(20)) a2 ();
  end
  if (M > 1) begin : gz
    v86_leaf #(.K(M + 7), .AddrW(21)) a3 ();
    for (genvar hh = 0; hh < 2; hh++) begin : gn
      localparam int NP = 6;
      localparam logic[17:0] n_add = ~(('h1 << (NP + hh)) - 1'b1);
      v86_leaf #(.K(hh + 9), .AddrW(22)) a4 ();
    end
  end
endmodule

// NEVER INSTANTIATED: the DEF listing only.  Must stay byte-identical.
module v86_orphan #(parameter int AddrW = 17) ();
  localparam int P = 8;
  localparam int W = 5;
  localparam logic[AddrW-1:0] d_add = ~(('h1 << (P + W)) - 1'b1);
  localparam logic[AddrW-1:0] d_mul = ~(('h1 << (P * W)) - 1'b1);
endmodule

module top86_v8 ();
  v86_mid #(.M(2)) m0 ();
  v86_mid #(.M(5)) m1 ();
endmodule
