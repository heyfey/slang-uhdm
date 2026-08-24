// r10v117 (verifier) arm b4 — THE `= new` FENCE (§ classPropNewLhsNoHoist109)
// AND THE DYNAMIC-ARRAY FORM, now that a FREE PACKAGE SUBROUTINE reaches
// § oobRefVarLocalHoistNet107.  Two TOP modules, one of which imports the
// package and one of which does not.  MEASUREMENT ONLY.
package PkgNewFence;

  class Payload4;
    int val4;
    function new(int v = 0); val4 = v; endfunction
  endclass

  function automatic int newFenceFnV4();
    semaphore  newLhsPlainF1;      // 01 `= new(...)`      -- FENCED, no wire
    semaphore  newLhsBareF2;       // 02 `= new()`         -- FENCED, no wire
    process    ordinaryLhsF3;      // 03 an ORDINARY lvalue -- the wire
    Payload4   copySrcF4;          // 04 the COPY form's SOURCE
    Payload4   copyDstF5;          // 05 `= new src`        -- FENCED
    int        dynCountF6;         // C1 an int (not a ref_var)
    process    slotArrF7[4];       // C2 an ARRAY of a builtin class
    int        idxKappaF8;         // 06 a SELECT INDEX inside a `= new` lvalue
    newLhsPlainF1 = new(1);                                    // 01
    newLhsBareF2  = new();                                     // 02
    ordinaryLhsF3 = process::self();                           // 03
    copySrcF4     = null;
    copyDstF5     = new copySrcF4;                             // 04 05
    dynCountF6    = 3;
    idxKappaF8    = 2;
    slotArrF7[idxKappaF8] = process::self();                   // 06 C2
    return dynCountF6;
  endfunction

  task automatic newFenceTaskV4();
    semaphore taskNewLhsG1;        // 07 `= new` inside a free TASK -- FENCED
    process   taskOrdinaryG2;      // 08 an ordinary lvalue in the same task
    taskNewLhsG1  = new(2);
    taskOrdinaryG2 = process::self();
  endtask

endpackage

import PkgNewFence::*;
module TopFenceImports;          // TOP 1 -- imports the package
  int rv4;
  initial begin
    rv4 = newFenceFnV4();
    newFenceTaskV4();
  end
endmodule

module TopFenceNoImport;         // TOP 2 -- names nothing of the package
  int quietV4;
  initial quietV4 = 0;
endmodule
