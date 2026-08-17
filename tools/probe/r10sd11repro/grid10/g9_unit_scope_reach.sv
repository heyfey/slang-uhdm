// r10sd10 grid cell g9 — the SCOPE-NAMEABILITY axis, and the cell that proves
// question (3) REACH is NOT redundant with question (4) ORDER.
//
// Surelog's `paClass_scope` arm rebuilds the owner's map key as
// `<something>::<written scope name>` and looks it up.  A `$unit`-level class
// is registered as `work@<name>`, a spelling none of the three lookups ever
// produces, so at `$unit` scope the owner is NEVER reached — even when it is
// compiled, and even when it is the DECLARING CLASS ITSELF.  The same shape
// inside a MODULE resolves, because a module's own name (`work@top`) is exactly
// what the lookup prepends.
//
// The BARE spelling is unaffected: it reaches the typedef through
// `component->getDataType`, a LEXICAL lookup with no key reconstruction in it.
class aholder;                       // $unit, sorts BEFORE zuser
  typedef struct { int a; } arec_t;
endclass

class selfu;                         // $unit, uses its OWN typedef both ways
  typedef struct { int a; } orec_t;
  function void f();
    selfu::orec_t v_unit_self_scoped;   // SCOPED  -> class_var (unreachable)
    orec_t        v_unit_self_bare;     // BARE    -> struct_var (lexical)
    v_unit_self_scoped.a = 1;
    v_unit_self_bare.a = 1;
  endfunction
endclass

class zuser;                         // $unit sibling, owner sorts BEFORE
  function void f();
    aholder::arec_t v_unit_sibling;     // SCOPED  -> class_var (unreachable)
    v_unit_sibling.a = 1;
  endfunction
endclass

class zbase;
  typedef struct { int a; } zrec_t;
endclass

class achild extends zbase;          // $unit, INHERITED bare, base sorts AFTER
  function void g();
    zrec_t v_unit_inh_bare;             // BARE    -> ref_var (order)
    v_unit_inh_bare.a = 1;
  endfunction
endclass

module top;
  class mholder;                     // MODULE scope: the lookup DOES spell it
    typedef struct { int a; } mrec_t;
  endclass
  class zmuser;
    function void f();
      mholder::mrec_t v_mod_sibling;    // SCOPED  -> struct_var (reachable)
      v_mod_sibling.a = 1;
    endfunction
  endclass

  selfu s;
  zuser z;
  achild c;
  zmuser zm;
  initial begin s = new(); z = new(); c = new(); zm = new(); end
endmodule
