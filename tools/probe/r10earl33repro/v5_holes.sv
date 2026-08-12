// r10earl33 VERIFIER arm — THE EMPTY PRODUCT CELLS of the shipped grid.
//
// b1_gen/b2_init/b3_text hold `container x initialiser x spelling` but leave
// four products of (generate x call-kind x guard) unmeasured.  Each cell below
// is one of them, and each is a place where § genScopeBareArgKeepsRef33's gate
//   fcArgPos32 && !fcArgQual33 && (inGenScopeCaRhs || inGenScopeProc)
// is WIDER than § genNestedScopePkgParamNoFold24's, which the pass claims it
// is "the third container" of:
//   law 24:  ... && !inLhs && !inParamInit && !currentTf && <nesting>
//   law 33:  <no such exclusions, and no nesting test>
//
//   h1  a TASK CALL argument in an elab gen PROCESS, BARE and QUALIFIED
//       (the gate names uhdmtask_call; no shipped cell exercises it)
//   h2  a bare read reached by an EXPLICIT (non-wildcard) import
//       (every shipped bare cell uses `import p::*`)
//   h3  a bare read inside a FUNCTION BODY called from a gen-scope process
//       (law 24 excludes `currentTf`; law 33 does not)
//   h4  a bare read in a gen-scope LOCALPARAM initialiser
//       (law 24 excludes `inParamInit`; law 33 does not)
package h33;
  localparam logic [11:0] P = 12'h380;
endpackage

module h33m (output logic [31:0] y);
  import h33::*;              // wildcard, for h1/h3/h4
  import h33::P;              // explicit, for h2

  logic [31:0] t1, t2, t3, t4, t5;

  task automatic tk(input logic [11:0] v, output logic [31:0] o);
    o = {v, 20'h0};
  endtask
  // h3's function: its BODY reads the bare package parameter.
  function automatic logic [31:0] fbody(logic [11:0] u);
    return {u, 20'h0} ^ {P, 20'h0};
  endfunction
  function automatic logic [31:0] mf(logic [11:0] v); return {v, 20'h0}; endfunction

  // h1 — TASK CALL in an elaborated generate process, bare then qualified
  for (genvar gi = 0; gi < 2; gi++) begin : gtask
    logic [31:0] wb, wq;
    always_comb tk(P, wb);
    always_comb tk(h33::P, wq);
  end
  assign t1 = gtask[0].wb;
  assign t2 = gtask[0].wq;

  // h2 — EXPLICIT-import bare read, gen cont-assign and gen process
  for (genvar gj = 0; gj < 2; gj++) begin : gexp
    logic [31:0] wc, wp;
    assign wc = mf(P);
    always_comb wp = mf(P);
  end
  assign t3 = gexp[0].wc;

  // h3 — the bare read lives in a FUNCTION BODY invoked from a gen process
  for (genvar gk = 0; gk < 2; gk++) begin : gfn
    logic [31:0] w;
    always_comb w = fbody(12'h1);
  end
  assign t4 = gfn[0].w;

  // h4 — the bare read is a gen-scope LOCALPARAM initialiser's call argument
  for (genvar gl = 0; gl < 2; gl++) begin : gpar
    localparam logic [31:0] L = mf(P);
    logic [31:0] w;
    assign w = L;
  end
  assign t5 = gpar[0].w;

  assign y = t1 ^ t2 ^ t3 ^ t4 ^ t5;
endmodule

module h33top;
  logic [31:0] a;
  h33m u1 (.y(a));
endmodule
