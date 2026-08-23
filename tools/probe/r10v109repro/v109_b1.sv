// r10v109repro/v109_b1.sv - ADVERSARIAL: a CLASS PROPERTY used as an INDEX (or
// deeper) INSIDE the LHS of a `= new`.  classNewAsgLhs109 walks UP to the
// nearest AssignmentExpression and returns TRUE for ANYTHING that came up the
// LEFT side, so an index sub-expression is fenced together with the base.
// Surelog compiles a select's INDEX through the ordinary compileExpression
// road, which DOES call needLateBinding - so golden may well mint that wire.
// MEASUREMENT ONLY.
package pkb1;

  class Cell1;
    int q;
    function new(int a = 0); q = a; endfunction
  endclass

  class Rig1;
    Cell1 slotArr[8];
    Cell1 deepArr[4][4];
    int   idxKappa;        // class property, used ONLY as an index in a `= new` LHS
    int   idxOmega;        // ditto, second dimension
    int   idxLambda;       // ditto, used in an `= new[n]` LHS index (array-new)
    int   dynBag[];
    int   ctlSigma;        // CONTROL: an ordinary plain LHS
    int   ctlTau;          // CONTROL: an index of an ORDINARY (non-new) LHS
    int   plainArr[8];
    extern function void b1set();
    extern function void b1ctl();
  endclass

  function void Rig1::b1set();
    slotArr[idxKappa]           = new(1);   // C1 property as index, class-new LHS
    deepArr[idxOmega][idxKappa] = new(2);   // C2 two indices, one repeated
  endfunction

  function void Rig1::b1ctl();
    plainArr[ctlTau] = 5;                   // C3 property as index of an ORDINARY LHS
    ctlSigma         = 6;                   // C4 plain LHS control
    dynBag           = new[idxLambda];      // C5 array-new, property in the SIZE (rhs)
  endfunction

endpackage

import pkb1::*;

module topb1;
  Rig1 r1;
  initial begin
    r1 = new();
    r1.b1set();
    r1.b1ctl();
  end
endmodule
