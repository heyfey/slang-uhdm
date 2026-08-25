// r10uvm130repro/g130_a1.sv — THE CONTEXT GRID.  MEASUREMENT ONLY.
// ONE home (an OUT-OF-BODY method of a PACKAGE class), ONE declaration kind (a
// plain `int` body local), and the SAME name read in every expression context
// this law could plausibly reach.  Every cell has its OWN name, so an arm that
// agrees for the wrong reason cannot hide (RESUME §9).
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
package p130a;

  class kls130a;
    int propMu130a;
    static int statNu130a;
    function new(int seedPi130a = 0);
      statNu130a = seedPi130a;
    endfunction
    extern function int ctx130a(int farmXi130a);
  endclass

  // OUT-OF-BODY: the home every corpus site of this law has.
  function int kls130a::ctx130a(int farmXi130a);
    int sizeAlpha130a;
    int opndBeta130a;
    int idxDelta130a;
    int rhsEps130a;
    int argZeta130a;
    int condEta130a;
    int retTheta130a;
    int newArgIota130a;
    int dynA130a[];
    int dynB130a[];
    int srcLam130a[];
    int fixedArr130a[8];
    kls130a hOmega130a;

    sizeAlpha130a = 4;
    // 01  the BARE SIZE argument — the head's own shape
    dynA130a = new[sizeAlpha130a];
    // 02  the size as an OPERATION OPERAND
    dynB130a = new[opndBeta130a + 1];
    // 03  the COPY-SOURCE (init) argument
    dynA130a = new[3](srcLam130a);
    // 04  a METHOD-CALL RECEIVER inside the size — a hier_path element
    dynB130a = new[srcLam130a.size()];
    // 05  an ordinary assignment RHS, same declaration kind
    fixedArr130a[0] = rhsEps130a;
    // 06  a SELECT INDEX outside any new[]
    fixedArr130a[1] = fixedArr130a[idxDelta130a];
    // 07  a USER CALL argument outside any new[]
    statNu130a = sink130a(argZeta130a);
    // 08  a CONDITION operand
    if (condEta130a == 0)
      statNu130a = 1;
    // 09  a CLASS `new(...)` ARGUMENT — Surelog PARENTS that call, so it binds
    hOmega130a = new(newArgIota130a);
    // 10  a RETURN operand
    return retTheta130a + farmXi130a;
  endfunction

  function int sink130a(int vSig130a);
    return vSig130a;
  endfunction

endpackage

import p130a::*;

module top130a;
  initial begin
    kls130a k130a;
    k130a = new(1);
    $display("%0d", k130a.ctx130a(2));
  end
endmodule
