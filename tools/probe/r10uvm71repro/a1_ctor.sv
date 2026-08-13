// r10uvm71 arm a1 -- WHERE DO A SUBROUTINE'S BODY LOCALS HANG?
//
// The head: golden gives `function (uvm_pkg::uvm_objection::new)` NO
// vpiVariables vector while we give it three -- and the body `begin` block,
// which is byte-identical on both sides, already lists them.
//
// The SimpleUVM census says the split is CONSTRUCTOR vs EVERYTHING ELSE
// (golden: 0 of 290 constructors carry vpiVariables, 665 of the other
// subroutines do; ours matches on all 665 and differs on exactly 5).  This arm
// asks WHICH property of a constructor does it -- the NAME `new`, the
// declaration FORM (in-body / out-of-body extern), the class being
// PARAMETERIZED, the lifetime, or the presence of a `super.new` call -- and it
// carries POSITIVE CONTROLS (ordinary method, task, module function, package
// function) that MUST keep their variables, so a patch that simply stops
// emitting vpiVariables everywhere is refuted by this file alone.
//
// Every subroutine below declares at least one body local, because a
// subroutine with no locals cannot distinguish the two policies.

package p1;

  // ---- c_base: in-body constructor WITH locals, plus the positive controls.
  class c_base;
    int m_i;

    // CELL 1: in-body constructor, body locals, no super.new.
    function new(string nm = "");
      int    ctor_loc_a;
      string ctor_loc_b;
      ctor_loc_a = 1;
      ctor_loc_b = nm;
      m_i = ctor_loc_a;
    endfunction

    // CELL 2 (POSITIVE CONTROL): ordinary method with body locals.  golden
    // KEEPS these on the function -- 665 subroutines in SimpleUVM prove it.
    function int meth_with_locals(int a);
      int    meth_loc_a;
      string meth_loc_b;
      meth_loc_a = a + 1;
      meth_loc_b = "x";
      return meth_loc_a;
    endfunction

    // CELL 3 (POSITIVE CONTROL): task with body locals.
    task task_with_locals(int a);
      int task_loc_a;
      task_loc_a = a;
      m_i = task_loc_a;
    endtask

    // CELL 4: a method NAMED like a constructor is impossible, but a STATIC
    // method with locals is the nearest neighbour that still lives in a class.
    static function int stat_with_locals(int a);
      int stat_loc_a;
      stat_loc_a = a;
      return stat_loc_a;
    endfunction
  endclass

  // ---- c_oob: OUT-OF-BODY (extern) constructor with locals, and an
  // out-of-body ordinary method with locals as its control.
  class c_oob;
    int m_j;
    extern function new(int k);
    extern function int oob_meth(int a);
  endclass

  function c_oob::new(int k);
    int oob_ctor_loc;
    oob_ctor_loc = k;
    m_j = oob_ctor_loc;
  endfunction

  function int c_oob::oob_meth(int a);
    int oob_meth_loc;
    oob_meth_loc = a;
    return oob_meth_loc;
  endfunction

  // ---- c_super: constructor that CALLS super.new -- the five UVM cells all
  // do; this separates "is a constructor" from "calls super.new".
  class c_super extends c_base;
    int m_k;
    function new(string nm = "");
      int sup_ctor_loc;
      super.new(nm);
      sup_ctor_loc = 7;
      m_k = sup_ctor_loc;
    endfunction
  endclass

  // ---- c_inh: NO constructor of its own; inherits c_base's.  Its class_defn
  // must not acquire one, and nothing here may change.
  class c_inh extends c_base;
    int m_l;
    function int inh_meth(int a);
      int inh_loc;
      inh_loc = a;
      return inh_loc;
    endfunction
  endclass

  // ---- c_param: PARAMETERIZED class with a constructor carrying locals.
  class c_param #(int W = 8);
    int m_w;
    function new(int v);
      int par_ctor_loc;
      par_ctor_loc = v + W;
      m_w = par_ctor_loc;
    endfunction
    function int par_meth(int a);
      int par_meth_loc;
      par_meth_loc = a;
      return par_meth_loc;
    endfunction
  endclass

  // ---- c_auto: constructor whose locals are written `automatic`, so the
  // lifetime keyword cannot be mistaken for the discriminator.
  class c_auto;
    int m_m;
    function new();
      automatic int auto_ctor_loc = 3;
      m_m = auto_ctor_loc;
    endfunction
  endclass

  // ---- POSITIVE CONTROL: a PACKAGE-level function with body locals.
  function int pkg_fn(int a);
    int pkg_fn_loc;
    pkg_fn_loc = a;
    return pkg_fn_loc;
  endfunction

endpackage

module a1;
  import p1::*;

  // POSITIVE CONTROL: a MODULE-level function with body locals.
  function int mod_fn(int a);
    int mod_fn_loc;
    mod_fn_loc = a;
    return mod_fn_loc;
  endfunction

  c_base       h_base;
  c_oob        h_oob;
  c_super      h_super;
  c_inh        h_inh;
  c_param #(4) h_param;
  c_auto       h_auto;
  int          r;

  initial begin
    h_base  = new("b");
    h_oob   = new(2);
    h_super = new("s");
    // c_inh has NO constructor of its own: the IMPLICIT derived-class
    // constructor takes no arguments (it super.new()s with none), so this is
    // `new()` and not `new("i")` -- slang rejects the latter outright.
    h_inh   = new();
    h_param = new(3);
    h_auto  = new();
    r = mod_fn(1) + pkg_fn(2) + h_base.meth_with_locals(3)
      + c_base::stat_with_locals(4) + h_oob.oob_meth(5)
      + h_inh.inh_meth(6) + h_param.par_meth(7);
    h_base.task_with_locals(8);
  end
endmodule
