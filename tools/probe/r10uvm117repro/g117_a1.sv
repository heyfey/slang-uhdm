// r10uvm117 arm a1 — THE REFERENCE-POSITION GRID for a `ref_var` local of a
// FREE PACKAGE SUBROUTINE.  MEASUREMENT ONLY.
//
// Every cell carries its OWN name (a grid that calls everything a_t/b_t/c_t is
// self-confirming — RESUME §9), so "one implicit wire per NAME per module"
// cannot merge two answers.  The builtin `process` / `semaphore` classes are
// the ref_var producers (§ builtinClassLocalUnsupportedBeforeClassPhase115:
// a package subroutine's body local typed by one degrades to `ref_var` +
// `unsupported_typespec` on BOTH sides); the user class and the int are the
// RESOLVED controls that must keep binding their own declarations.
package pk117a;

  class helper117a;
    int fld;
    function int ask(int a); return a; endfunction
    function void take(int a); endfunction
  endclass

  function automatic void sink117a(process q);
  endfunction

  // ---- THE FAMILY HOME: a FREE PACKAGE FUNCTION -------------------------
  function automatic int freeFn117a(int gate);
    process    asgLhsAlpha;      // 01 ordinary assignment LVALUE (THE HEAD's own position)
    process    rhsReadBeta;      // 02 plain RHS read
    process    condGamma;        // 03 an `if` CONDITION operand
    process    userArgDelta;     // 04 a user call ARGUMENT
    process    sysArgEpsilon;    // 05 a SYSTEM-call argument ($cast)
    semaphore  newLhsZeta;       // 06 the `= new` LVALUE — THE FENCE
    process    stmtCallEta;      // 07 a receiver call, STATEMENT position
    process    exprCallTheta;    // 08 a receiver call, EXPRESSION position
    process    arrIdxKappa[2];   // 09 an ELEMENT-SELECT base
    helper117a resolvedCtlXi;    // C1 a USER class handle — RESOLVES
    int        intCtlOmicron;    // C2 an int local — RESOLVES
    asgLhsAlpha = process::self();                                     // 01
    asgLhsAlpha = rhsReadBeta;                                         // 02
    if (condGamma == null) intCtlOmicron = 1;                          // 03
    sink117a(userArgDelta);                                            // 04
    void'($cast(sysArgEpsilon, rhsReadBeta));                          // 05
    newLhsZeta = new(1);                                               // 06
    stmtCallEta.kill();                                                // 07
    if (exprCallTheta.status() == process::RUNNING) intCtlOmicron = 2;  // 08
    sink117a(arrIdxKappa[0]);                                          // 09
    resolvedCtlXi = new();                                             // C1
    resolvedCtlXi.take(intCtlOmicron);                                 // C1
    intCtlOmicron = gate;                                              // C2
    return intCtlOmicron;
  endfunction

  // the RETURN operand needs a function whose return type is the family's.
  function automatic process retFn117a();
    process retIota;             // 10 a RETURN operand
    return retIota;
  endfunction

  // a BLOCK-ITEM local (§ 115's SITE 2), read as an ordinary lvalue.
  function automatic void blkFn117a(int gate);
    if (gate > 0) begin
      process blkLocalLambda;    // 11
      blkLocalLambda = process::self();
    end
  endfunction

  // ---- THE FAMILY'S OTHER HALF: a FREE PACKAGE TASK ---------------------
  task automatic freeTask117a();
    process taskLocalNu;         // 12
    taskLocalNu = process::self();
  endtask

endpackage

import pk117a::*;
module top117a;
  initial begin
    void'(freeFn117a(1));
    void'(retFn117a());
    blkFn117a(1);
    freeTask117a();
  end
endmodule
