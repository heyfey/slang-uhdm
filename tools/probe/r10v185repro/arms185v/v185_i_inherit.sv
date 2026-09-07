// r10uvm185 VERIFIER arm I — THE INHERITANCE AXIS, an axis the pass's own grid
// never enters: the return typedef is owned by a BASE class, not by the class
// that carries the `extern` prototype, and it is named BARE (inherited lookup)
// as well as SCOPED.
//
// Why this is the axis: § classTdLocalVarKindFollowsCompileOrder10's BARE arm
// answers `ownerCompiled = self || (sibling && owner.name < ctx.cls->name)`.
// In the PROTOTYPE listing the patched law now asks that question with
// `ctx.cls` = the DERIVED class and `owner` = the BASE class, so the answer
// swings on the LEAF NAMES.  Both directions are carried:
//   `ab_base185` < `cd_der185`   (base sorts BEFORE  — the law resolves)
//   `zb_base185` > `md_der185`   (base sorts AFTER   — the law must not)
// The pristine binary answered `ref_var` / `class_var` for every one of them
// (the prototype listing was asked about the OUT-OF-BODY definition, whose
// `outOfBlockIndex` forces the fallback), so every cell here is a cell the
// patch can move.
package pi185;

  class ab_base185;                       // sorts BEFORE cd_der185
    typedef enum { AB0, AB1 }   ab_enum;
    typedef struct { int a; }   ab_rec;
    typedef ab_enum             ab_alias;      // NAMED base
    typedef int                 ab_int;
  endclass

  class zb_base185;                       // sorts AFTER md_der185
    typedef enum { ZB0, ZB1 }   zb_enum;
    typedef struct { int z; }   zb_rec;
  endclass

  class cd_der185 extends ab_base185;
    // BARE — the inherited lookup
    extern function ab_enum            i_inh_bare_enum();
    extern function ab_rec             i_inh_bare_rec();
    extern function ab_alias           i_inh_bare_alias();
    extern function ab_int             i_inh_bare_int();
    // SCOPED at the BASE
    extern function ab_base185::ab_enum  i_inh_scoped_enum();
    extern function ab_base185::ab_rec   i_inh_scoped_rec();
    extern function ab_base185::ab_alias i_inh_scoped_alias();
    // SCOPED at the DERIVED class (legal: the member is inherited)
    extern function cd_der185::ab_enum   i_inh_selfscoped_enum();
    // an IN-BODY control on the same types: this law never fires there
    function ab_enum i_body_bare_enum();  endfunction
    function ab_base185::ab_rec i_body_scoped_rec(); endfunction
  endclass

  class md_der185 extends zb_base185;
    extern function zb_enum              i_late_bare_enum();
    extern function zb_base185::zb_rec   i_late_scoped_rec();
  endclass

  function ab_base185::ab_enum  cd_der185::i_inh_bare_enum();      endfunction
  function ab_base185::ab_rec   cd_der185::i_inh_bare_rec();       endfunction
  function ab_base185::ab_alias cd_der185::i_inh_bare_alias();     endfunction
  function ab_base185::ab_int   cd_der185::i_inh_bare_int();       endfunction
  function ab_base185::ab_enum  cd_der185::i_inh_scoped_enum();    endfunction
  function ab_base185::ab_rec   cd_der185::i_inh_scoped_rec();     endfunction
  function ab_base185::ab_alias cd_der185::i_inh_scoped_alias();   endfunction
  function ab_base185::ab_enum  cd_der185::i_inh_selfscoped_enum(); endfunction
  function zb_base185::zb_enum  md_der185::i_late_bare_enum();     endfunction
  function zb_base185::zb_rec   md_der185::i_late_scoped_rec();    endfunction

endpackage

module top185i;
  pi185::cd_der185 d;
  pi185::md_der185 e;
  initial begin d = new(); e = new(); end
endmodule
