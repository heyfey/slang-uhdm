// v131 arm I — fork-local declarations WITHOUT initialisers (the UnitElabBlock
// shape) in every join flavour, named / unnamed / end-labelled, plus a
// declaration-only fork that is otherwise statement-empty.
module Idecl;
  int drive;
  initial begin
    fork : innerwave reg hold; join
    fork : wave2 reg hold2; join_any : wave2
    fork : wave3 logic [3:0] hold3; join_none : wave3
    fork reg holdU; join
    fork reg holdV; join_any
    fork reg holdW; join_none
    // two declarations, no initialisers
    fork : twoDecl reg h1; reg h2; join_none : twoDecl
    // a declaration AND a statement
    fork : mixDecl reg h3; drive = 1; join_any : mixDecl
    // a declaration WITH an initialiser (the other branch)
    fork : initDecl reg h4 = 1'b0; join_none : initDecl
  end
endmodule
