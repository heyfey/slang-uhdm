// r10uvm185 grid arm A — THE CONTEXT AXIS of
// § externProtoRetVarKindIsPrototypeCompile185.
//
// Every `e_*` method is `extern`, so golden builds TWO function objects for it:
// the CLASS-BODY PROTOTYPE listing (no body, spanning the `extern` keyword) and
// the OUT-OF-BODY DEFINITION listing.  The law says the PROTOTYPE listing's
// return variable is compiled IN THE CLASS from the PROTOTYPE LINE, and the
// DEFINITION listing's is not — so the two listings of ONE method are allowed
// to carry DIFFERENT variable classes, and this arm is built so that they do.
//
// The `i_*` twins are the same return types on ordinary IN-BODY methods: this
// law never runs there and every one of them must stay byte-identical.
//
// Class sort order (§ classTdLocalVarKindFollowsCompileOrder10's term 4 is a
// LEAF-NAME comparison): `ah185` < `user185` < `zh185`.  The arm therefore
// carries BOTH directions — an owner that sorts BEFORE the declaring class
// (resolves in the class-body compile) and one that sorts AFTER (does not) —
// so an arm that AGREES because the law never fired is distinguishable from one
// that agrees because the law fired correctly.
package pa185;

  class ah185;                       // sorts BEFORE user185
    typedef struct { int a; }      ah_rec;
    typedef enum { AE0, AE1 }      ah_enum;
    typedef int                    ah_int;
    typedef bit [7:0]              ah_vec;
    typedef ah_enum                ah_alias;   // a NAMED base in a sibling
  endclass

  class zh185;                       // sorts AFTER user185
    typedef struct { int z; }      zh_rec;
    typedef enum { ZE0, ZE1 }      zh_enum;
  endclass

  class user185;
    typedef struct { int o; }      own_rec;
    typedef enum { OE0, OE1 }      own_enum;
    // a NAMED-BASE typedef of the class's OWN inline enum: Surelog's
    // `ElaborationStep::bindTypedefs_` binds it AFTER the class compile, so the
    // class-body listing has no typespec for it (§ ownNamedAliasRetIsRefVar177's
    // mechanism).  Returned BARE from the prototype and SCOPED from the
    // definition, and again the other way round.
    typedef own_enum               own_alias;
    // the ARRAY row: a FIXED unpacked array typedef RESOLVES (golden
    // `array_var`), a QUEUE / DYNAMIC / ASSOCIATIVE one is DECLINED by the law
    // and must keep the pristine object.  Both returned BARE from the
    // prototype, which is the spelling `g185_e_kinds.sv` does NOT carry.
    typedef int                    own_arr[4];
    typedef int                    own_q[$];

    // ---- IN-BODY controls: this law never fires; must not move -----------
    function ah185::ah_rec   i_early_rec();    endfunction
    function ah185::ah_enum  i_early_enum();   endfunction
    function zh185::zh_rec   i_late_rec();     endfunction
    function zh185::zh_enum  i_late_enum();    endfunction
    function own_rec         i_own_bare();     endfunction
    function user185::own_rec i_own_scoped();  endfunction

    // ---- THE CONTEXT AXIS: the SAME scoped spelling on both lines --------
    // Only `outOfBody` separates the two listings here.
    extern function ah185::ah_rec   e_early_rec();
    extern function ah185::ah_enum  e_early_enum();
    extern function ah185::ah_int   e_early_int();
    extern function ah185::ah_vec   e_early_vec();
    // ...and the owner that sorts AFTER: BOTH listings must stay `class_var`,
    // which is this arm's negative control.
    extern function zh185::zh_rec   e_late_rec();
    extern function zh185::zh_enum  e_late_enum();

    // ---- THE SPELLING AXIS: BARE on the prototype, SCOPED on the ---------
    // definition (the LRM requires the class scope out of body), so the two
    // listings ask law 10 two DIFFERENT questions.
    extern function own_rec         e_own_rec();
    extern function own_enum        e_own_enum();
    extern function own_alias       e_own_alias();
    extern function own_arr         e_own_arr();
    extern function own_q           e_own_q();

    // ---- a SCOPED own-class spelling on both lines -----------------------
    extern function user185::own_rec  e_own_scoped();
    extern function user185::own_alias e_alias_scoped();
    // and a NAMED-BASE typedef owned by a SIBLING class, scoped both ways
    extern function ah185::ah_alias   e_early_alias();
  endclass

  function ah185::ah_rec   user185::e_early_rec();   endfunction
  function ah185::ah_enum  user185::e_early_enum();  endfunction
  function ah185::ah_int   user185::e_early_int();   endfunction
  function ah185::ah_vec   user185::e_early_vec();   endfunction
  function zh185::zh_rec   user185::e_late_rec();    endfunction
  function zh185::zh_enum  user185::e_late_enum();   endfunction
  function user185::own_rec  user185::e_own_rec();   endfunction
  function user185::own_enum user185::e_own_enum();  endfunction
  function user185::own_rec   user185::e_own_scoped();  endfunction
  function user185::own_alias user185::e_own_alias();   endfunction
  function user185::own_arr   user185::e_own_arr();     endfunction
  function user185::own_q     user185::e_own_q();       endfunction
  function user185::own_alias user185::e_alias_scoped(); endfunction
  function ah185::ah_alias    user185::e_early_alias();  endfunction

endpackage

module top185a;
  pa185::user185 u;
  initial u = new();
endmodule
