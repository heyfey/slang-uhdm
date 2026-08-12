// r10earl33 VERIFIER arm 2 — the two EXCLUSIONS § genNestedScopePkgParamNoFold24
// carries that § genScopeBareArgKeepsRef33 does NOT, exercised as call arguments:
//   law 24: genNestedScopeEmit24 && !defGenProcessEmit && (inGenScopeCaRhs ||
//           inGenScopeProc) && !inLhs && !inParamInit && !currentTf && <bare>
//   law 33: fcArgPos32 && !fcArgQual33 && (inGenScopeCaRhs || inGenScopeProc)
//
//   j1  a bare pkg-param CALL ARGUMENT inside a FUNCTION declared IN the
//       generate block and called from that block's process   (currentTf)
//   j2  the same, called from that block's CONT-ASSIGN
//   j3  a bare pkg-param call argument in a gen-scope LOCALPARAM initialiser
//       that is itself inside a NESTED generate scope          (inParamInit)
package j33;
  localparam logic [11:0] P = 12'h380;
endpackage

module j33m (output logic [31:0] y);
  import j33::*;
  function automatic logic [31:0] mf(logic [11:0] v); return {v, 20'h0}; endfunction

  logic [31:0] s1, s2, s3;

  // j1 / j2 — a function DECLARED INSIDE the generate block whose BODY holds
  // the bare package-parameter call argument.
  for (genvar gi = 0; gi < 2; gi++) begin : gtf
    logic [31:0] wp, wc;
    function automatic logic [31:0] inner();
      return mf(P);
    endfunction
    always_comb wp = inner();
    assign wc = inner();
  end
  assign s1 = gtf[0].wp;
  assign s2 = gtf[0].wc;

  // j3 — a NESTED generate scope whose LOCALPARAM initialiser is the call.
  if (1) begin : gout
    for (genvar gj = 0; gj < 2; gj++) begin : gin
      localparam logic [31:0] L = mf(P);
      logic [31:0] w;
      assign w = L ^ mf(P);
    end
  end
  assign s3 = gout.gin[0].w;

  assign y = s1 ^ s2 ^ s3;
endmodule

module j33top;
  logic [31:0] a;
  j33m u1 (.y(a));
endmodule
