// r10v130repro/v130_b1.sv — VERIFIER ARM b1: the READ FACE grid.
// Every cell has its OWN name.  One home throughout (an OUT-OF-BODY method of a
// package class, the shape § newArrayArgHoistNet130 claims), one declaration
// kind (a plain body local); what varies is WHERE the name is read.
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
package pkFace130v;

  function int helperTakesOne130v(int oneArg130v);
    return oneArg130v + 1;
  endfunction

  class cFace130v;
    int dynTargetKappa130v[];
    int queueLambdaSrc130v[$];
    int fixedMuArr130v[8];
    extern function void faceRunner130v(int formalNuUnused130v);
  endclass

  function void cFace130v::faceRunner130v(int formalNuUnused130v);
    // c01 a name used as a QUEUE INDEX *inside* the new[] size argument
    int qIndexOmega130v;
    // c02 a name used as the argument of a NESTED function call inside new[]
    int nestedCallRho130v;
    // c03 a name used as a TERNARY condition inside new[]
    int ternCondSigma130v;
    // c04 / c05 the two ternary branches inside new[]
    int ternThenTau130v;
    int ternElseUps130v;
    // c06 a name inside $bits() inside new[]
    int bitsArgPhi130v;
    // c07 a name used as a CONCATENATION element inside new[]
    int concatChi130v;
    // c08 a LOOP BOUND, OUTSIDE any new[] — must bind normally, mint nothing
    int loopBoundPsi130v;
    // c09 a WHILE CONDITION, outside new[]
    int whileCondAlp130v;
    // c10 a name read only on the LHS of an ordinary assignment
    int lhsOnlyBet130v;
    // c11 a name read as an ARRAY SELECT INDEX outside new[]
    int selIdxGam130v;
    // c12 a name read inside a DELAY control, outside new[]
    int delayDel130v;
    qIndexOmega130v   = 0;
    nestedCallRho130v = 1;
    ternCondSigma130v = 1;
    ternThenTau130v   = 2;
    ternElseUps130v   = 3;
    bitsArgPhi130v    = 4;
    concatChi130v     = 1;
    loopBoundPsi130v  = 2;
    whileCondAlp130v  = 0;
    selIdxGam130v     = 1;
    delayDel130v      = 1;
    queueLambdaSrc130v.push_back(7);
    dynTargetKappa130v = new[queueLambdaSrc130v[qIndexOmega130v]];          // c01
    dynTargetKappa130v = new[helperTakesOne130v(nestedCallRho130v)];        // c02
    dynTargetKappa130v = new[ternCondSigma130v ? ternThenTau130v
                                               : ternElseUps130v];          // c03,c04,c05
    dynTargetKappa130v = new[$bits(bitsArgPhi130v)];                        // c06
    dynTargetKappa130v = new[{concatChi130v, 1'b0}];                        // c07
    for (int iFace130v = 0; iFace130v < loopBoundPsi130v; iFace130v++)      // c08
      fixedMuArr130v[0] = fixedMuArr130v[selIdxGam130v];                    // c11
    while (whileCondAlp130v != 0) whileCondAlp130v = 0;                     // c09
    lhsOnlyBet130v = 5;                                                     // c10
    fixedMuArr130v[1] = formalNuUnused130v + delayDel130v;                  // c12
  endfunction

endpackage

import pkFace130v::*;

module topFace130v;
  initial begin
    cFace130v hFace130v;
    hFace130v = new();
    hFace130v.faceRunner130v(3);
  end
endmodule
