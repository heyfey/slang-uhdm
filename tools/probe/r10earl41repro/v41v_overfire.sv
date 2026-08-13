// r10earl41 VERIFIER over-fire arm — shapes § pkgWrittenQualSelBase41 can reach
// that the shipped 19-cell grid does NOT cover.
package pv41;
  parameter int DW = 8;
  parameter logic [3:0][7:0] A = {8'h1, 8'h2, 8'h3, 8'h4};
  logic [3:0][7:0] V;                       // a package VARIABLE, not a param
  logic [3:0][7:0] W;
  typedef struct packed { logic [7:0] f; } st_t;
endpackage

package outer41;
  parameter logic [3:0][7:0] Z = {8'h1, 8'h2, 8'h3, 8'h4};
  class kls41;
    static logic [3:0][7:0] M;
  endclass
endpackage

module sink41 #(parameter int W = 8) (input logic [W-1:0] p);
endmodule

module v41v_overfire #(parameter int DW = 8) (input logic [1:0] sel, output logic [7:0] o);
  logic [7:0] r1, r2, r3, r4, r5, r6, r7;

  // o1 — package VARIABLE written qualified, RHS, two selectors.
  always_comb r1 = pv41::V[sel][DW-1:0];

  // o2 — package VARIABLE written qualified on the LHS of a procedural assign.
  always_comb begin
    pv41::W[sel][DW-1:0] = 8'h5;
  end

  // o3 — package-qualified base as a PORT HIGH-CONN (SITE 2 port guard).
  sink41 #(.W(8)) u1 (.p(pv41::A[sel][DW-1:0]));

  // o4 — package-qualified base inside a FUNCTION body.
  function automatic logic [7:0] f41(input logic [1:0] s);
    f41 = pv41::A[s][DW-1:0];
  endfunction
  always_comb r2 = f41(sel);

  // o5 — CLASS static member reached through a package: parent scope is the
  // CLASS, so the predicate must NOT fire.
  always_comb r3 = outer41::kls41::M[sel][DW-1:0];

  // o6 — qualified base written inside an INDEX of another select.
  always_comb r4 = pv41::A[pv41::V[0][1:0]][DW-1:0];

  // o7 — qualified base, NO trailing range, three element selects.
  logic q7;
  always_comb q7 = pv41::A[sel][0];

  // o8 — a `+:` indexed range on a qualified base (the F4/R3 shape) in the
  // AST path.
  logic [3:0] r5v;
  always_comb r5v = pv41::A[sel][0 +: 4];

  // o9 — bare (unqualified via import) reference to the SAME package var.
  import pv41::*;
  always_comb r6 = V[sel][DW-1:0];

  assign o = r1 ^ r2 ^ r3 ^ r4 ^ {7'b0,q7} ^ {4'b0,r5v} ^ r6;
endmodule
