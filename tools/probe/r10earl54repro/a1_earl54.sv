// r10earl54 GRID a1 — WHERE does a REPLICATION fold to a full-width BIN
// constant?  Every cell is a replication with a CONSTANT-FOLDABLE body
// ({W{1'b0}}); what varies is the CONTEXT it sits in.
//
// The Earlgrey head is `.wdata({..., c ? x : {32{1'b0}}, ...})` — a
// replication nested TWO levels inside a port-connection actual.  earl52's
// fence F2 measured a PARAMETER INITIALIZER replication as a DIFFERENT
// shape, so context is the discriminator and this grid enumerates it.
//
// Read the golden dump per named object; nothing here is a cmp head claim.
package pk54;
  parameter int W = 8;
endpackage

module sink54 #(parameter int WD = 8) (
  input  [WD-1:0] a,
  input  [WD-1:0] b,
  output [WD-1:0] o
);
  assign o = a ^ b;
endmodule

module a1_earl54 (
  input  logic       clk,
  input  logic       sel,
  input  logic [7:0] d,
  output logic [7:0] q
);

  logic [7:0] w_direct, w_cat, w_ter, w_bin, w_deep, w_nonc, w_ca, w_pr;

  // C1 — the replication IS the whole actual (the arm we already have).
  sink54 #(.WD(8)) u_direct (.a({8{1'b0}}), .b(d), .o(w_direct));

  // C2 — the replication is a CONCAT OPERAND (depth 1).
  sink54 #(.WD(8)) u_cat (.a({{4{1'b0}}, {4{1'b1}}}), .b(d), .o(w_cat));

  // C3 — THE HEAD SHAPE: replication is a TERNARY arm inside a CONCAT
  //      (depth 2), the ternary's other arm NON-constant.
  sink54 #(.WD(8)) u_ter (.a({sel ? d[3:0] : {4{1'b0}}, 4'h5}), .b(d), .o(w_ter));

  // C4 — replication as a BINARY operand (depth 1), other side non-constant.
  sink54 #(.WD(8)) u_bin (.a(d | {8{1'b1}}), .b(d), .o(w_bin));

  // C5 — replication THREE levels down: concat > ternary > binary.
  sink54 #(.WD(8)) u_deep (.a({sel ? (d[3:0] & {4{1'b1}}) : 4'h0, 4'h2}), .b(d),
                           .o(w_deep));

  // C6 — replication with a NON-CONSTANT body: must NOT fold.
  sink54 #(.WD(8)) u_nonc (.a({sel ? {4{d[0]}} : 4'h0, 4'h3}), .b(d), .o(w_nonc));

  // C7 — the SAME shapes in a CONT-ASSIGN RHS (Surelog's writeCont_assign
  //      path).  If golden folds here too, that is a SEPARATE law/residue.
  assign w_ca = {sel ? d[3:0] : {4{1'b0}}, 4'h5};

  // C8 — the SAME shape in a PROCEDURAL statement.
  always_comb begin
    w_pr = {sel ? d[3:0] : {4{1'b0}}, 4'h6};
  end

  // C9 — replication in a PARAMETER OVERRIDE actual (a param actual, not a
  //      port actual: a third context).
  sink54 #(.WD($bits({8{1'b0}}))) u_pov (.a(d), .b(d), .o(q));

  // C10 — a NESTED replication ({2{{2{1'b1}}}}) as a concat operand.
  sink54 #(.WD(8)) u_nest (.a({{2{{2{1'b1}}}}, 4'h7}), .b(d), .o());

  // C11 — replication whose COUNT is a PACKAGE parameter.
  sink54 #(.WD(8)) u_pkgc (.a({sel ? d : {pk54::W{1'b0}}}), .b(d), .o());

  // C12 — a plain CONSTANT BINARY (no replication) nested in a conn actual:
  //       does golden fold `4'h3 + 4'h1` too?  Tells whether the law is
  //       "replication" or "every foldable subexpression".
  sink54 #(.WD(8)) u_cbin (.a({sel ? d[3:0] : (4'h3 + 4'h1), 4'h8}), .b(d), .o());

endmodule
