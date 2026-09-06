// r10v177 adversarial arm 5 — THE INHERITED ALIAS, WITH THE NAME ORDER BOTH
// WAYS.  r10uvm177's arm D calls `cv_inherited` (a BASE class's alias named
// from the child) a cell that MUST NOT MOVE, and reports both binaries already
// answering golden's `ref_var` there.  They do — but for a different reason:
// § classTdLocalVarKindFollowsCompileOrder10's ORDER term compares the two
// class LEAF NAMES, and `Parent177` sorts AFTER `Child177`, so that law
// answers `RefVar` before § 177 is ever asked.  RESUME §9: an arm AGREEING
// with golden is not an arm TESTING the law.
//
// This arm asks the same question with the order BOTH ways, in one file:
//   Aaa5  (base sorts FIRST)  <- Zzz5   : the order term says "compiled",
//                                         so § 10 answers `Resolved` and the
//                                         cell is decided by § 177 alone;
//   Yyy5  (base sorts LAST)   <- Bbb5   : the order term says "not compiled",
//                                         so § 10 answers `RefVar` regardless.
// Each base carries BOTH an inline-base typedef and an alias OF that typedef,
// so the two halves of § 177's term (3) are separated as well.

package inhp5;
  class Aaa5;                       // base, EARLY-sorting name
    typedef enum { A_R, A_S } AaaDirect;   // inline base
    typedef AaaDirect AaaRef;              // NAMED base
    function AaaDirect aOwnDirect(); return A_R; endfunction
    function AaaRef    aOwnVia();    return A_S; endfunction
  endclass

  class Zzz5 extends Aaa5;          // derived, LATE-sorting name
    typedef enum { Z_T, Z_U } ZzzDirect;
    typedef ZzzDirect ZzzRef;
    function AaaDirect zInhDirect(); return A_R; endfunction  // inherited, inline base
    function AaaRef    zInhVia();    return A_S; endfunction  // inherited, NAMED base
    function ZzzRef    zOwnVia();    return Z_T; endfunction  // own alias
  endclass

  class Yyy5;                       // base, LATE-sorting name
    typedef enum { Y_M, Y_N } YyyDirect;
    typedef YyyDirect YyyRef;
    function YyyDirect yOwnDirect(); return Y_M; endfunction
    function YyyRef    yOwnVia();    return Y_N; endfunction
  endclass

  class Bbb5 extends Yyy5;          // derived, EARLY-sorting name
    typedef enum { B_P, B_Q } BbbDirect;
    typedef BbbDirect BbbRef;
    function YyyDirect bInhDirect(); return Y_M; endfunction
    function YyyRef    bInhVia();    return Y_N; endfunction
    function BbbRef    bOwnVia();    return B_P; endfunction
  endclass

  // A THREE-deep chain of classes, so "the compiling component" is asked about
  // a grandparent's alias too.
  class Kid5 extends Zzz5;
    function AaaRef kGrandVia();  return A_S; endfunction
    function ZzzRef kParentVia(); return Z_U; endfunction
  endclass
endpackage

module InhBench5;
  import inhp5::*;
  Zzz5 z5 = new(); Bbb5 b5 = new(); Kid5 k5 = new();
  initial $display(z5.zInhDirect(), z5.zInhVia(), z5.zOwnVia(),
                   b5.bInhDirect(), b5.bInhVia(), b5.bOwnVia(),
                   k5.kGrandVia(), k5.kParentVia(),
                   z5.aOwnDirect(), z5.aOwnVia(), b5.yOwnDirect(), b5.yOwnVia());
endmodule
