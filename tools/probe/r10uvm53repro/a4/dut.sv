// r10uvm53repro/a4 — TARGET 2's two cells, with the OUT-OF-BODY and PACKAGE
// twins that keep the gate from getting too wide, and the four extra
// EXPRESSION spellings of a bare call that the first cut of this arm did not
// have (operation operand, nested argument, while-condition, return).
//
// Pass 52's law `classInBodyRecvCallArgNoBind52` is
//     curSubClassScope9 && !curSubOob9 && recvCallArgDepth52 > 0
// (IN BODY + RECEIVER-QUALIFIED + NON-STATEMENT).  It left two known-wrong
// binds standing, and this arm measures both on BOTH SIDES:
//
//   f1 — the DEEP-RECEIVER arm.  `grep -n 'bool deepRecv11' src/ExprEmit.cpp`
//        mints a hier_path AND emits call arguments with no RecvCallArg52
//        window, so a two-segment receiver (`mid.leaf.m53(f)`) never reached
//        pass 52's law.  Cells f1_ib_cond_deep / f1_ob_cond_deep.
//
//   f2 — the R-VALUE BARE call.  `§ classArgBind12` only ever saw the
//        STATEMENT and if-CONDITION spellings of a bare call.
//        Cells f2_ib_rval_* / f2_ob_rval_*, with the statement and condition
//        twins beside them as the controls that must NOT move.
//
// Pass 52 recorded that ITS r-value cell was polluted: Surelog emits
// `CP0332 Function "bare52" is not defined for variable "this"` when a class
// method calls a PACKAGE function bare.  So here the bare callee is a METHOD
// OF THE SAME CLASS — the real corpus spelling — and cells.sh's caller checks
// surelog.log for CP0332.
//
// LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.

package p53c;

  class leaf53;
    function int m53(int v);
      return v;
    endfunction
  endclass

  class mid53;
    leaf53 leaf;
  endclass

  class ib53;                        // IN BODY
    mid53 mid;

    function int self53(int v);
      return v;
    endfunction

    function int ib_all(int f);
      int loc;
      loc = 0;
      self53(f);                     // f2_ib_stmt_bare   (control: golden BINDS)
      if (self53(f) == 0)            // f2_ib_cond_bare   (control: golden BINDS)
        return 1;
      loc = self53(f);               // f2_ib_rval_bare   <-- TARGET 2 / R2
      loc = self53(f) + 1;           // f2_ib_rval_op_bare
      loc = self53(self53(f));       // f2_ib_rval_nest_bare
      while (self53(f) == 99)        // f2_ib_while_bare
        break;
      if (mid.leaf.m53(f) == 0)      // f1_ib_cond_deep   <-- TARGET 2 / THE MISS
        return 2;
      loc = mid.leaf.m53(f);         // f1_ib_rval_deep
      mid.leaf.m53(f);               // f1_ib_stmt_deep   (control)
      return self53(f) + loc;        // f2_ib_ret_bare
    endfunction
  endclass

  class ob53;                        // OUT OF BODY — every cell's twin
    mid53 mid;
    extern function int self53(int v);
    extern function int ob_all(int f);
  endclass

  function int ob53::self53(int v);
    return v;
  endfunction

  function int ob53::ob_all(int f);
    int loc;
    loc = 0;
    self53(f);                       // f2_ob_stmt_bare
    if (self53(f) == 0)              // f2_ob_cond_bare
      return 1;
    loc = self53(f);                 // f2_ob_rval_bare
    loc = self53(f) + 1;             // f2_ob_rval_op_bare
    loc = self53(self53(f));         // f2_ob_rval_nest_bare
    while (self53(f) == 99)          // f2_ob_while_bare
      break;
    if (mid.leaf.m53(f) == 0)        // f1_ob_cond_deep
      return 2;
    loc = mid.leaf.m53(f);           // f1_ob_rval_deep
    mid.leaf.m53(f);                 // f1_ob_stmt_deep
    return self53(f) + loc;          // f2_ob_ret_bare
  endfunction

  // PACKAGE subroutine control — golden binds these and nothing here may move.
  mid53 pk_mid;
  function automatic int pk_bare53(int v);
    return v;
  endfunction
  function automatic int pk_all(int f);
    int loc;
    loc = 0;
    pk_bare53(f);                    // f2_pk_stmt_bare
    if (pk_bare53(f) == 0)           // f2_pk_cond_bare
      return 1;
    loc = pk_bare53(f);              // f2_pk_rval_bare
    loc = pk_bare53(f) + 1;          // f2_pk_rval_op_bare
    if (pk_mid.leaf.m53(f) == 0)     // f1_pk_cond_deep
      return 2;
    loc = pk_mid.leaf.m53(f);        // f1_pk_rval_deep
    return pk_bare53(f) + loc;       // f2_pk_ret_bare
  endfunction

endpackage

module a4_top;
  import p53c::*;
  ib53 i1;
  ob53 o1;
  initial begin
    i1 = new();
    o1 = new();
  end
endmodule
