// r10v86 va5 — SUBTREE SHAPES the implementer's g1 did not spell: A+B+C with
// explicit grouping, (A+B)*C, A+(B*C), a ternary with a PARAM condition, a
// concat INSIDE a foldable subtree, a $clog2 call inside, a literal-only
// subtree, and a subtree with ONE BARE identifier operand which must keep
// earl85's leaf form.  GOLDEN = Surelog.
package v86e_pkg;
  localparam int EP = 3;
endpackage
module v86_shp #(parameter int AddrW = 20, parameter int SELP = 1) ();
  localparam int A = 8;
  localparam int B = 5;
  localparam int C = 2;
  localparam logic [7:0] LW = 8'd3;

  localparam logic[AddrW-1:0] k_abc  = ~(('h1 << (A + B + C)) - 1'b1);
  localparam logic[AddrW-1:0] k_abc2 = ~(('h1 << (A + (B + C))) - 1'b1);
  localparam logic[AddrW-1:0] k_pmc  = ~(('h1 << ((A + B) * C)) - 1'b1);
  localparam logic[AddrW-1:0] k_apc  = ~(('h1 << (A + (B * C))) - 1'b1);
  localparam logic[AddrW-1:0] k_smc  = ~(('h1 << ((A - B) * C)) - 1'b1);
  localparam logic[AddrW-1:0] k_shb  = ~(('h1 << ((A << 1) + C)) - 1'b1);
  // ternary with a PARAM condition (both polarities, and a param-only cond)
  localparam logic[AddrW-1:0] k_tp1  = ~(('h1 << (SELP ? A : B)) - 1'b1);
  localparam logic[AddrW-1:0] k_tp2  = ~(('h1 << ((SELP == 0) ? A : B)) - 1'b1);
  localparam logic[AddrW-1:0] k_tp3  = ~(('h1 << ((SELP ? A : B) + C)) - 1'b1);
  localparam logic[AddrW-1:0] k_tp4  = ~(('h1 << (A + (SELP ? B : C))) - 1'b1);
  localparam logic[AddrW-1:0] k_tnest= ~(('h1 << (SELP ? (A + B) : (A * B))) - 1'b1);
  // a CONCAT inside a foldable subtree
  localparam logic[AddrW-1:0] k_cat1 = ~(('h1 << ({2'b01, 2'b10} + A)) - 1'b1);
  localparam logic[AddrW-1:0] k_cat2 = ~(('h1 << ({LW[1:0], 2'b11} + C)) - 1'b1);
  localparam logic[AddrW-1:0] k_rep1 = ~(('h1 << ({2{2'b01}} + C)) - 1'b1);
  // a $clog2 CALL inside
  localparam logic[AddrW-1:0] k_clg1 = ~(('h1 << ($clog2(A) + B)) - 1'b1);
  localparam logic[AddrW-1:0] k_clg2 = ~(('h1 << ($clog2(A + B))) - 1'b1);
  localparam logic[AddrW-1:0] k_clg3 = ~(('h1 << (($clog2(A) + $clog2(B)) * C)) - 1'b1);
  localparam logic[AddrW-1:0] k_bits = ~(('h1 << ($bits(LW) + C)) - 1'b1);
  // LITERAL-ONLY subtrees
  localparam logic[AddrW-1:0] k_lit1 = ~(('h1 << (4 + 5)) - 1'b1);
  localparam logic[AddrW-1:0] k_lit2 = ~(('h1 << (8'd4 + 8'd5)) - 1'b1);
  localparam logic[AddrW-1:0] k_lit3 = ~(('h1 << (32'h4 * 3)) - 1'b1);
  localparam logic[AddrW-1:0] k_lit4 = ~(('h1 << (4 + 5 + 6)) - 1'b1);
  // ONE BARE identifier operand — earl85's leaf form must survive untouched
  localparam logic[AddrW-1:0] k_bar1 = ~(('h1 << A) - 1'b1);
  localparam logic[AddrW-1:0] k_bar2 = ~(('h1 << LW) - 1'b1);
  localparam logic[AddrW-1:0] k_bar3 = ~(('h1 << v86e_pkg::EP) - 1'b1);
  localparam logic[AddrW-1:0] k_bar4 = ('h1 << A) - A;
  // a SELECT operand (not a BinaryOp/UnaryOp shape the walk can pair)
  localparam logic[AddrW-1:0] k_sel1 = ~(('h1 << (LW[1:0] + C)) - 1'b1);
  localparam logic[AddrW-1:0] k_sel2 = ~(('h1 << (LW[2] + C)) - 1'b1);
endmodule

module top86_v5 ();
  v86_shp #(.AddrW(20), .SELP(1)) i0 ();
  v86_shp #(.AddrW(21), .SELP(0)) i1 ();
  v86_shp #(.AddrW(22), .SELP(2)) i2 ();
endmodule
