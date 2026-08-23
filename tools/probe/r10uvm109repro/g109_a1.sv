// r10uvm109repro/g109_a1.sv - THE REFERENCE-POSITION GRID for a CLASS PROPERTY
// named from an OUT-OF-BODY method body.  MEASUREMENT ONLY.
//
// One DISTINCT property name per syntactic position, so the "one implicit wire
// per NAME per module" rule cannot make two cells share an answer.  Names are
// deliberately unlike each other in length, case and digits (a grid whose arms
// are all `a_t/b_t/c_t` is self-confirming, RESUME law9).
package pk109;

  class Helper9;
    int fld;
    function new(int a = 0); fld = a; endfunction
    function int ask(int v); return v + fld; endfunction
    task take(int v); fld = v; endtask
  endclass

  class Inner77;
    Helper9 hh;
    int num;
    function new(); hh = new(1); endfunction
  endclass

  class Gadget;
    Helper9 newLhsA;
    Helper9 newLhsArgB;
    int     newArrC[];
    Helper9 plainAsgD;
    Helper9 dotLhsE;
    Helper9 bareReadF;
    Helper9 memReadG;
    Inner77 chainReadH;
    Helper9 stmtCallJ;
    Helper9 exprCallK;
    Inner77 chainCallL;
    int     idxSelM[4];
    Helper9 idxObjN[4];
    int     callArgP;
    Helper9 callArgMemQ;
    int     thisMemR;
    int     lhsPlainS;
    int     rhsPlainT;
    int     sysArgU;
    int     condV;
    int     retW;
    int     ibOnlyZ;

    extern function void oob_new_lhs();
    extern function void oob_asg_lhs();
    extern function int  oob_reads();
    extern task          oob_calls();
    extern function int  oob_args();
    extern function int  oob_ret();
    // THE CONTROL: an IN-BODY method reading the same kind of property.
    function int in_body_read();
      ibOnlyZ = ibOnlyZ + 1;
      return ibOnlyZ;
    endfunction
  endclass

  function void plain9(int v); endfunction

  // ---- cells 01..03: the `= new` family (the corpus head's shape)
  function void Gadget::oob_new_lhs();
    newLhsA    = new();          // 01 class-new LHS, no args
    newLhsArgB = new(7);         // 02 class-new LHS, with args
    newArrC    = new[3];         // 03 array-new LHS
  endfunction

  // ---- cells 04..05: ordinary assignment LHS
  function void Gadget::oob_asg_lhs();
    plainAsgD  = null;           // 04 plain ref_obj LHS
    dotLhsE.fld = 4;             // 05 hier_path LHS (`prop.member = ...`)
    lhsPlainS  = 9;              // 17 scalar plain LHS
  endfunction

  // ---- cells 06..08, 12..13, 16, 18: reads
  function int Gadget::oob_reads();
    Helper9 loc9;
    int k9;
    loc9 = bareReadF;            // 06 bare read
    k9   = memReadG.fld;         // 07 `prop.member`
    k9   = k9 + chainReadH.hh.fld; // 08 `prop.member.member`
    k9   = k9 + idxSelM[1];      // 12 `prop[i]`
    k9   = k9 + idxObjN[2].fld;  // 13 `prop[i].member`
    k9   = k9 + this.thisMemR;   // 16 `this.prop`
    k9   = k9 + rhsPlainT;       // 18 plain RHS read
    return k9;
  endfunction

  // ---- cells 09..11, 20: calls and conditions
  task Gadget::oob_calls();
    stmtCallJ.take(2);           // 09 receiver call, STATEMENT position
    if (exprCallK.ask(1) == 0)   // 10 receiver call, EXPRESSION position
      chainCallL.hh.take(3);     // 11 CHAINED receiver call
    if (condV == 0)              // 20 condition operand
      plain9(1);
  endtask

  // ---- cells 14, 15, 19: argument positions
  function int Gadget::oob_args();
    plain9(callArgP);            // 14 user call argument, bare
    plain9(callArgMemQ.fld);     // 15 user call argument, `prop.member`
    $display("%0d", sysArgU);    // 19 system-call argument
    return 0;
  endfunction

  // ---- cell 21: return
  function int Gadget::oob_ret();
    return retW;                 // 21 return operand
  endfunction

endpackage

import pk109::*;

module top109;
  Gadget g9;
  int r9;
  initial begin
    g9 = new();
    g9.oob_new_lhs();
    g9.oob_asg_lhs();
    r9 = g9.oob_reads();
    g9.oob_calls();
    r9 = r9 + g9.oob_args();
    r9 = r9 + g9.oob_ret();
    r9 = r9 + g9.in_body_read();
  end
endmodule
