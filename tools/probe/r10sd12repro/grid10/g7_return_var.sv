// r10sd10 grid cell g7 — the RETURN-VARIABLE site.
// Surelog compiles a function's return value with the SAME `compileVariable`,
// so § classTdLocalVarKindFollowsCompileOrder10 governs it too.  This is the
// `uvm_resource_pool::lookup_name` family: six SeqDriver rows whose return type
// is `uvm_resource_types::rsrc_q_t` — a CLASS-HANDLE typedef nested in a class
// that sorts AFTER the declaring one — where golden says `class_var` and
// § aliasClassRefVar10 says `ref_var`.
package px;

  class kx;
    int q;
  endclass

  class aholder;
    typedef struct { int a; } arec_t;
    typedef kx acls_t;
  endclass

  class zholder;
    typedef struct { int a; } zrec_t;
    typedef kx zcls_t;
  endclass

  class muser;                          // aholder < muser < zholder
    // owner sorts BEFORE -> resolved
    function aholder::arec_t r_early_struct(); endfunction
    function aholder::acls_t r_early_cls();    endfunction
    // owner sorts AFTER  -> class_var
    function zholder::zrec_t r_late_struct();  endfunction
    function zholder::zcls_t r_late_cls();     endfunction
    // the class's OWN typedef, scoped and bare
    typedef struct { int a; } orec_t;
    function orec_t       r_own_bare();        endfunction
    function muser::orec_t r_own_scoped();     endfunction
    // OUT-OF-BODY return of the same shapes
    extern function aholder::arec_t r_ext_early();
    extern function orec_t          r_ext_own();
  endclass

  function aholder::arec_t muser::r_ext_early(); endfunction
  function muser::orec_t   muser::r_ext_own();   endfunction
  // A BARE own-typedef return on an out-of-body definition is measured on the
  // GOLDEN side only (`ref_var`, at BOTH the prototype and the definition span)
  // and is NOT a cell here: slang rejects the shape outright —
  // "return type for out-of-block method must use class scope 'muser::' to
  // access nested type" — so our emitter can never be asked the question.

endpackage

module top;
  px::muser m;
  initial m = new();
endmodule
