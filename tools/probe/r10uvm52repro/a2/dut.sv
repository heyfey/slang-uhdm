// r10uvm52 arm a2 — THE PREDICATE GRID for call-argument binding.
//
// LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.
//
// a1 measured that golden binds NO class-method call argument in any of its six
// cells while binding the package one.  The corpus flatly contradicts a
// "class method" gate: golden binds 272 class-method hier-path call arguments
// in SimpleUVM's own database (measured with dumptree.py/bindiff.py after the
// container-priority fix — see README §2).  Reading the uvm-1.2 sources at the
// bound sites shows what a1 could not, because a1 had no such cell:
//
//     uvm_default_factory::set_type_override_by_name   uvm_factory.svh:998
//         -- the class ENDS at line 494; this body is OUT OF BODY  -> BOUND
//     uvm_pool::get                                    uvm_pool.svh:86
//         -- inside `class uvm_pool` (35..232), IN BODY            -> BARE
//     uvm_root::m_find_all_recurse (out of body)       -> BOUND
//     uvm_root::phase_started      (in body)           -> BARE
//         -- the SAME CLASS both ways, which is the cell that kills every
//            per-class theory
//
// So this arm varies exactly three axes and reads golden on all of them:
//   A. where the body is written:  IN BODY  vs  OUT OF BODY  vs  PACKAGE fn
//   B. the call's syntactic position: STATEMENT / if-CONDITION / r-value
//   C. the callee form: bare call / user method through a handle /
//      BUILT-IN method on an associative array (the corpus head's form)
// with the argument held constant as a FORMAL of the enclosing routine, plus
// LOCAL and CLASS-PROPERTY argument controls and a non-argument control.
//
// Cell numbering is <axisA><axisB><axisC>; every cell is named in the source so
// the arm table in the README can be checked against this file line by line.
package p52b;

  class hnd52;
    function int um52(int v);
      return v;
    endfunction
    function void ut52(int v);
    endfunction
  endclass

  function automatic int bare52(int v);
    return v;
  endfunction

  class ib52;                       // A = IN BODY
    int    amap[string];            // assoc array -> built-in methods
    hnd52  h;
    int    prop;

    // B = STATEMENT
    function void ib_stmt_bare(int f);
      int loc;
      loc = 0;
      bare52(f);                    // ib_stmt_bare_formal
      bare52(loc);                  // ib_stmt_bare_local
      bare52(prop);                 // ib_stmt_bare_prop
      h.ut52(f);                    // ib_stmt_hnd_formal
    endfunction

    // B = if CONDITION
    function int ib_cond(string k, int f);
      if (amap.exists(k))           // ib_cond_builtin_formal  <-- corpus head shape
        return f;
      if (bare52(f) == 0)           // ib_cond_bare_formal
        return 1;
      if (h.um52(f) == 0)           // ib_cond_hnd_formal
        return 2;
      return amap[k] + f;           // ib_nocall_index_formal (control: no call)
    endfunction

    // B = r-value
    function int ib_rval(int f);
      int loc;
      loc = bare52(f);              // ib_rval_bare_formal
      loc = h.um52(f);              // ib_rval_hnd_formal
      return loc;
    endfunction
  endclass

  class ob52;                       // A = OUT OF BODY
    int    amap[string];
    hnd52  h;
    int    prop;
    extern function void ob_stmt_bare(int f);
    extern function int  ob_cond(string k, int f);
    extern function int  ob_rval(int f);
  endclass

  function void ob52::ob_stmt_bare(int f);
    int loc;
    loc = 0;
    bare52(f);                      // ob_stmt_bare_formal
    bare52(loc);                    // ob_stmt_bare_local
    bare52(prop);                   // ob_stmt_bare_prop
    h.ut52(f);                      // ob_stmt_hnd_formal
  endfunction

  function int ob52::ob_cond(string k, int f);
    if (amap.exists(k))             // ob_cond_builtin_formal  <-- the BOUND corpus shape
      return f;
    if (bare52(f) == 0)             // ob_cond_bare_formal
      return 1;
    if (h.um52(f) == 0)             // ob_cond_hnd_formal
      return 2;
    return amap[k] + f;             // ob_nocall_index_formal
  endfunction

  function int ob52::ob_rval(int f);
    int loc;
    loc = bare52(f);                // ob_rval_bare_formal
    loc = h.um52(f);                // ob_rval_hnd_formal
    return loc;
  endfunction

  // A = PACKAGE subroutine (the pass-51 control, re-measured here)
  int pk_amap[string];
  function automatic int pk_all(string k, int f);
    int loc;
    hnd52 lh;
    loc = 0;
    lh = new();
    bare52(f);                      // pk_stmt_bare_formal
    lh.ut52(f);                     // pk_stmt_hnd_formal
    if (pk_amap.exists(k))          // pk_cond_builtin_formal
      return f;
    if (bare52(f) == 0)             // pk_cond_bare_formal
      return 1;
    loc = bare52(f);                // pk_rval_bare_formal
    loc = lh.um52(f);               // pk_rval_hnd_formal
    return loc + pk_amap[k];        // pk_nocall_index_formal
  endfunction

endpackage

module a2_top;
  import p52b::*;
  ib52 i1;
  ob52 o1;
  initial begin
    i1 = new();
    o1 = new();
  end
endmodule
