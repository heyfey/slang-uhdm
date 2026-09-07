// r10uvm185 VERIFIER arm J — THE INTRA-CLASS DECLARATION-ORDER AXIS, which the
// pass's grid never enters: the return typedef is written AFTER the `extern`
// prototype that names it, in the same class body.
//
// § classTdLocalVarKindFollowsCompileOrder10's ORDER term is a COMPARISON OF
// CLASS NAMES; it says nothing about the order of declarations INSIDE one
// class.  Now that the prototype listing asks that law about the prototype (so
// `self` is true and the answer is "resolved"), a typedef Surelog has not yet
// seen when it compiles that prototype line would be answered wrongly.  This
// arm carries both directions of the same shape, bare and scoped.
package pj185;

  class jbefore185;
    typedef enum { JB0, JB1 } jb_enum;      // BEFORE the prototypes
    typedef struct { int b; } jb_rec;
    extern function jb_enum             j_before_bare();
    extern function jbefore185::jb_rec  j_before_scoped();
  endclass

  class jafter185;
    extern function ja_enum             j_after_bare();
    extern function jafter185::ja_rec   j_after_scoped();
    typedef enum { JA0, JA1 } ja_enum;      // AFTER the prototypes
    typedef struct { int a; } ja_rec;
  endclass

  // The same question with the typedef sandwiched BETWEEN two prototypes.
  class jmid185;
    extern function jm_enum             j_mid_early();
    typedef enum { JM0, JM1 } jm_enum;
    extern function jm_enum             j_mid_late();
  endclass

  function jbefore185::jb_enum jbefore185::j_before_bare();   endfunction
  function jbefore185::jb_rec  jbefore185::j_before_scoped(); endfunction
  function jafter185::ja_enum  jafter185::j_after_bare();     endfunction
  function jafter185::ja_rec   jafter185::j_after_scoped();   endfunction
  function jmid185::jm_enum    jmid185::j_mid_early();        endfunction
  function jmid185::jm_enum    jmid185::j_mid_late();         endfunction

endpackage

module top185j;
  pj185::jbefore185 a;
  pj185::jafter185  b;
  pj185::jmid185    c;
  initial begin a = new(); b = new(); c = new(); end
endmodule
