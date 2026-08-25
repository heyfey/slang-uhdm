// r10uvm130repro/g130_a3.sv — THE DECLARATION-KIND GRID.  MEASUREMENT ONLY.
// ONE home (an OUT-OF-BODY method of a package class) and ONE context (the bare
// SIZE argument of a dynamic-array `new[...]`); what varies is WHAT THE NAME
// DECLARES.  § oobRefVarLocalHoistNet107's gate is `the declaration object is a
// ref_var`; this arm is the evidence that THIS law's gate must not be.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
package p130c;

  class kls130c;
    int    propMu130c;            // a class PROPERTY
    static int statNu130c;        // a STATIC class property
    int    dynC130c[];
    extern function void decls130c(int farmXi130c, ref int refArgPsi130c);
  endclass

  int pkgVarOmi130c;              // a PACKAGE variable

  function void kls130c::decls130c(int farmXi130c, ref int refArgPsi130c);
    int  bodyBeforeAlpha130c;     // a body local declared BEFORE the read
    kls130c handleTau130c;        // a CLASS-HANDLE local (our § 115 ref_var)
    bodyBeforeAlpha130c = 1;
    // 01  a body local declared BEFORE the read
    dynC130c = new[bodyBeforeAlpha130c];
    // 02  a FORMAL
    dynC130c = new[farmXi130c];
    // 03  a `ref` FORMAL
    dynC130c = new[refArgPsi130c];
    // 04  a CLASS PROPERTY
    dynC130c = new[propMu130c];
    // 05  a STATIC class property
    dynC130c = new[statNu130c];
    // 06  a PACKAGE variable
    dynC130c = new[pkgVarOmi130c];
    // 07  a BLOCK local
    begin
      int blkLocalGam130c;
      blkLocalGam130c = 2;
      dynC130c = new[blkLocalGam130c];
    end
    // 08  a NAMED-BLOCK local
    begin : nb130c
      int nmdBlkDel130c;
      nmdBlkDel130c = 3;
      dynC130c = new[nmdBlkDel130c];
    end
    // 09  a LOOP ITERATOR
    for (int loopIterEps130c = 0; loopIterEps130c < 2; loopIterEps130c++)
      dynC130c = new[loopIterEps130c + 1];
    // 10  NOT EXPRESSIBLE — SystemVerilog allows declarations only at the head
    //     of a block, so "a local declared AFTER the read" cannot be written in
    //     a subroutine body at all; cell 07's block local, whose declaration is
    //     LEXICALLY LATER than the reads of cells 01-06, is the nearest legal
    //     spelling and is measured there.
    // 11  a CLASS-HANDLE local read as a hier_path receiver under new[]
    dynC130c = new[handleTau130c.propMu130c];
  endfunction

endpackage

import p130c::*;

module top130c;
  initial begin
    int q130c;
    kls130c k130c;
    q130c = 4;
    k130c = new();
    k130c.decls130c(5, q130c);
  end
endmodule
