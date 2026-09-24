// r10uvm52 arm a1 — WHICH call-argument ref_obj does golden bind?
//
// The corpus head (SimpleUVM/SeqDriver/Scoreboard, all modes) is
//   uvm-1.2 base/uvm_pool.svh:87  `if (!pool.exists(key))` inside
//   `virtual function T get (KEY key);` in the GENERIC class uvm_pool #(KEY,T)
//   LHS golden : ref_obj (…::get::pool.exists::key)  NO  vpiActual
//   RHS ours   : ref_obj (…::get::key)               vpiActual -> io_decl (key)
//
// The pass-51 brief's model — "inside a CLASS METHOD a call-argument ref_obj
// carries NO vpiActual; inside a PACKAGE subroutine it DOES" — is REFUTED by
// the corpus itself (measured with dumptree.py/bindiff.py on SimpleUVM's own
// golden): golden binds 2402 vpiArgument ref_objs to io_decls inside
// class_defn methods, including `m_type_names.exists(original_type_name)`
// (uvm_default_factory) and `m_children.exists(name)` (uvm_component), which
// are the SAME SHAPE as uvm_pool's `pool.exists(key)`.
//
// So this arm's job is to find the axis that DOES separate them.  Every cell
// is a receiver-qualified call (method_func_call under a hier_path), which is
// the context the corpus head lives in, and the cells vary exactly one thing
// at a time:
//   c1  built-in `exists` on a CONCRETE assoc array, in a PLAIN class
//   c2  built-in `exists` on a CONCRETE assoc array, in a GENERIC class
//   c3  built-in `exists` on an array whose INDEX IS A TYPE PARAMETER,
//       in a GENERIC class            <-- the corpus head's exact shape
//   c4  user method through a handle of a PLAIN class, in a PLAIN class
//   c5  user method through a handle of a GENERIC-class SPECIALIZATION,
//       in a PLAIN class              <-- uvm_report_handler's shape
//   c6  user method through a handle of a PLAIN class, in a GENERIC class
//   c7  PACKAGE function calling a PACKAGE function (the pass-51 control)
//   c8  PACKAGE function calling a method through a handle
//   c9  the same argument name used OUTSIDE any call (bit-select index),
//       the control that says whether the rule is about CALLS at all
package p52a;

  class user52;
    function int m52(int v);
      return v;
    endfunction
  endclass

  class gen52 #(type KEY = int, type T = int);
    T      pool[KEY];        // index IS the type parameter — c3
    int    cmap[string];     // concrete assoc array in a GENERIC class — c2
    user52 uh;               // plain-class handle in a GENERIC class — c6

    function int c2_concrete(string k, int v);
      if (cmap.exists(k))    // c2
        return v;
      return 0;
    endfunction

    function T c3_typeparam(KEY k);
      T dv;
      if (!pool.exists(k))   // c3  <-- corpus head shape
        pool[k] = dv;
      return pool[k];        // c9  — same name, NOT a call argument
    endfunction

    function int c6_userhandle(int v);
      return uh.m52(v);      // c6
    endfunction
  endclass

  class plain52;
    int                     pmap[string];
    user52                  ph;
    gen52 #(string, int)    gh;   // handle of a GENERIC specialization

    function int c1_concrete(string k, int v);
      if (pmap.exists(k))    // c1
        return v;
      return 0;
    endfunction

    function int c4_userhandle(int v);
      return ph.m52(v);      // c4
    endfunction

    function int c5_generichandle(string k);
      return gh.c2_concrete(k, 1);  // c5
    endfunction
  endclass

  function automatic int pkgcallee52(int a, int b);
    return a + b;
  endfunction

  function automatic int c7_pkgcaller(int p, int v);
    return pkgcallee52(p, v);       // c7
  endfunction

  function automatic int c8_pkghandle(int v);
    user52 lh;
    lh = new();
    return lh.m52(v);               // c8
  endfunction

endpackage

module a1_top;
  import p52a::*;
  plain52 p1;
  initial p1 = new();
endmodule
