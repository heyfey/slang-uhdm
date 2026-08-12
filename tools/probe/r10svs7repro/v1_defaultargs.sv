// r10svs7 VERIFIER arm v1 — the EMPTY PRODUCT CELL the implementer's grid never
// visited: a covergroup whose FORMAL ARGUMENTS carry DEFAULTS, instantiated with
// FEWER written actuals than formals, plus a NAMED-argument instantiation.
//
// WHY THIS CELL.  slang's `CallExpression::bindArgs` (source/ast/expressions/
// CallExpression.cpp, the `else { expr = formal->getDefaultValue(); }` branch)
// pushes the DEFAULT expression into the bound argument vector for every formal
// the source did not write.  § covergroupNewCall7's emit half iterates
// `nge7.arguments` unconditionally, so it emits one `vpiArgument` per FORMAL.
// The neighbouring `case ExpressionKind::NewClass:` arm deliberately does NOT:
// § writtenCallArgs16 recounts the actuals off the SYNTAX (`nsy9->argList->
// parameters.size()`) and truncates, because Surelog emits only what the source
// WROTE.  If that law holds for covergroups too, cells G1/G2/G4 over-emit.
//
// One statement per procedural block: Surelog keeps only the LAST statement of a
// class constructor (the implementer's p3_ctorstmt hazard); module `initial`
// blocks are used here so the hazard cannot silently delete a cell, and each
// cell still gets its own block so a regression is unambiguous.
module v1;
  bit clk;

  covergroup cgd (int a = 5, int b = 7) @(posedge clk);
    cpa: coverpoint a;
    cpb: coverpoint b;
  endgroup

  cgd g1;
  cgd g2;
  cgd g3;
  cgd g4;

  // G1 — NO actual written; BOTH formals defaulted.
  initial begin
    g1 = new;
  end

  // G2 — ONE actual written; the second formal defaulted.
  initial begin
    g2 = new(1);
  end

  // G3 — BOTH actuals written (the control: written == formals).
  initial begin
    g3 = new(1, 2);
  end

  // G4 — a NAMED actual for the SECOND formal only; the first defaulted.
  initial begin
    g4 = new(.b(9));
  end
endmodule
