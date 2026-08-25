// r10v130repro/v130_b2.sv — VERIFIER ARM b2: the STATEMENT-SHAPE grid.
// The SAME read face (the bare size argument of a dynamic-array new[...]) in
// statement shapes Surelog builds through DIFFERENT productions than
// `CompileHelper::compileBlockingAssignment`'s paDynamic_array_new arm.  A
// DECLARATION INITIALIZER (`int a[] = new[n];`) is the adversarial cell: if
// Surelog parents that call, golden BINDS and a mint would be a widening.
// MEASUREMENT ONLY.  LHS is ALWAYS golden; RHS is ALWAYS ours.
package pkShape130v;

  class cShape130v;
    int dynBlockAsg130v[];
    int dynInsideIf130v[];
    int dynInsideCase130v[];
    int dynInsideFork130v[];
    int dynInsideLoop130v[];
    int dynNamedBlk130v[];
    extern function void shapeRunner130v();
    extern task shapeTaskRunner130v();
  endclass

  function void cShape130v::shapeRunner130v();
    // s01 THE CONTROL — a plain blocking assignment (the head's own shape)
    int ctrlBlkAsgEta130v;
    // s02 a DECLARATION INITIALIZER — a different Surelog production
    int declInitZet130v;
    // s03 inside an IF branch
    int inIfIotaX130v;
    // s04 inside a CASE item
    int inCaseKap130v;
    // s05 inside a FOR loop body
    int inLoopLam130v;
    // s06 inside a NAMED begin/end block
    int inNamedMuu130v;
    int localDeclArr130v[] = new[declInitZet130v];                 // s02
    ctrlBlkAsgEta130v = 1;
    inIfIotaX130v     = 2;
    inCaseKap130v     = 3;
    inLoopLam130v     = 4;
    inNamedMuu130v    = 5;
    dynBlockAsg130v = new[ctrlBlkAsgEta130v];                      // s01
    if (ctrlBlkAsgEta130v == 1)
      dynInsideIf130v = new[inIfIotaX130v];                        // s03
    case (ctrlBlkAsgEta130v)
      1: dynInsideCase130v = new[inCaseKap130v];                   // s04
      default: ;
    endcase
    for (int jShape130v = 0; jShape130v < 1; jShape130v++)
      dynInsideLoop130v = new[inLoopLam130v];                      // s05
    begin : namedShapeBlk130v
      dynNamedBlk130v = new[inNamedMuu130v];                       // s06
    end
    if (localDeclArr130v.size() == 0) ctrlBlkAsgEta130v = 0;
  endfunction

  // s07 the same face inside an OUT-OF-BODY TASK, and inside a FORK
  task cShape130v::shapeTaskRunner130v();
    int inForkNuu130v;
    int oobTaskXiX130v;
    inForkNuu130v  = 6;
    oobTaskXiX130v = 7;
    dynInsideFork130v = new[oobTaskXiX130v];                       // s07
    fork
      dynInsideFork130v = new[inForkNuu130v];                      // s08
    join_none
  endtask

endpackage

import pkShape130v::*;

module topShape130v;
  initial begin
    cShape130v hShape130v;
    hShape130v = new();
    hShape130v.shapeRunner130v();
    hShape130v.shapeTaskRunner130v();
  end
endmodule
