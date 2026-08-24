// r10v117 (verifier) arm b1 — THE REFERENCE POSITIONS r10uvm117's a1 DID NOT
// COVER, inside a FREE PACKAGE FUNCTION and a FREE PACKAGE TASK.
// MEASUREMENT ONLY.  Every cell has its OWN name; no two cells share a
// spelling, a length or a case pattern.
//
// The cell this arm exists for: `recvArgQ7`, an argument of a USER-CLASS
// RECEIVER method call.  § oobRefVarLocalHoistNet107's last conjunct is
// `!bind5 || recvUserMethodArgDepth107 > 0`, and r10uvm117's own a1 grid has
// no receiver-call ARGUMENT cell at all — it only has the handle as the
// RECEIVER (cells 07/08).  So the disjunct is now reachable from a free
// package subroutine and was never measured there.
package Pkv1;

  class Kv1cls;
    int seenCnt;
    function void takeIt(process argHandle);
      seenCnt = seenCnt + 1;
    endfunction
    function int giveIt(process argTwo);
      return 1;
    endfunction
  endclass

  // ---------------------------------------------------------- FREE FUNCTION
  function automatic int freeFnPositionsV1();
    process recvArgQ7;        // 01 argument of a USER-CLASS RECEIVER call
    process recvArgExprZ2;    // 02 same, in EXPRESSION position
    process ternCondN2;       // 03 ternary CONDITION operand
    process ternValY5;        // 04 ternary VALUE operand
    process eqRhsK8;          // 05 plain RHS of a comparison
    process dispArgU4;        // 06 argument of a SYSTEM TASK ($display)
    process freeCallArgB6;    // 07 argument of a FREE PACKAGE FUNCTION call
    process castDstW1;        // 08 $cast DESTINATION
    Kv1cls kk1;
    int rr1;
    kk1 = new();
    kk1.takeIt(recvArgQ7);                                    // 01
    rr1 = kk1.giveIt(recvArgExprZ2);                          // 02
    ternValY5 = (ternCondN2 == null) ? eqRhsK8 : null;        // 03 04 05
    $display("%p", dispArgU4);                                // 06
    rr1 = rr1 + sinkFnV1(freeCallArgB6);                      // 07
    void'($cast(castDstW1, eqRhsK8));                         // 08
    return rr1;
  endfunction

  function automatic int sinkFnV1(process pin);
    return 0;
  endfunction

  // -------------------------------------------------------------- FREE TASK
  task automatic freeTaskPositionsV1();
    process waitCondW3;       // 09 a WAIT event-control operand
    process fjLhsD9;          // 10 an lvalue inside fork/join_none
    process forInitH2;        // 11 an lvalue in a for-loop initialiser slot
    process repeatBodyL7;     // 12 an lvalue inside repeat
    int    intIdxNoRefV1;     // C1 an INT local -- NOT a ref_var, must not move
    int    intArrV1[4];
    wait (waitCondW3 == null);                                // 09
    fork
      fjLhsD9 = process::self();                              // 10
    join_none
    for (forInitH2 = process::self(); 0; ) begin end          // 11
    repeat (2) repeatBodyL7 = process::self();                // 12
    intIdxNoRefV1 = 1;
    intArrV1[intIdxNoRefV1] = 3;                              // C1
  endtask

endpackage

import Pkv1::*;
module TopBeeOne;
  int outV1;
  initial begin
    outV1 = freeFnPositionsV1();
    freeTaskPositionsV1();
  end
endmodule
