// r10uvm71 arm a2 -- THE SITE AXIS, and the patch's NEGATIVE CONTROL.
//
// a1 decided the discriminator (constructor vs everything else) inside a
// PACKAGE.  The five SimpleUVM cells are all package classes, so a package-only
// arm cannot tell "constructor" from "constructor in a package".  This arm puts
// the same constructor in every other site a class can occupy, and pairs each
// one with a NON-constructor sibling that must not move:
//
//   * a class declared directly in a MODULE
//   * a class nested inside another class
//   * a class declared in a COMPILATION UNIT (outside any package/module)
//   * a virtual class (abstract) with a constructor
//   * a constructor with NO body locals at all (nothing to remove; must be
//     byte-identical before and after)
//
// The `$unit` and module-scope cells are the ones that decide whether the gate
// may be written as `classScope || oob` or needs a scope test of its own.

class c_unit;                       // $unit-scope class
  int m_u;
  function new(int v);
    int unit_ctor_loc;
    unit_ctor_loc = v;
    m_u = unit_ctor_loc;
  endfunction
  function int unit_meth(int a);    // control: must keep its local
    int unit_meth_loc;
    unit_meth_loc = a;
    return unit_meth_loc;
  endfunction
endclass

module a2;

  // ---- class declared directly in a MODULE
  class c_mod;
    int m_m;
    function new(int v);
      int mod_ctor_loc;
      mod_ctor_loc = v;
      m_m = mod_ctor_loc;
    endfunction
    function int mod_meth(int a);   // control
      int mod_meth_loc;
      mod_meth_loc = a;
      return mod_meth_loc;
    endfunction
  endclass

  // ---- class NESTED inside another class
  class c_outer;
    int m_o;
    class c_inner;
      int m_i;
      function new(int v);
        int inner_ctor_loc;
        inner_ctor_loc = v;
        m_i = inner_ctor_loc;
      endfunction
    endclass
    function new(int v);
      int outer_ctor_loc;
      outer_ctor_loc = v;
      m_o = outer_ctor_loc;
    endfunction
  endclass

  // ---- VIRTUAL (abstract) class with a constructor carrying a local
  virtual class c_virt;
    int m_v;
    function new(int v);
      int virt_ctor_loc;
      virt_ctor_loc = v;
      m_v = virt_ctor_loc;
    endfunction
    pure virtual function int must_impl(int a);
  endclass

  class c_concrete extends c_virt;
    function new(int v);
      int conc_ctor_loc;
      super.new(v);
      conc_ctor_loc = v;
      m_v = conc_ctor_loc;
    endfunction
    virtual function int must_impl(int a);
      int impl_loc;                 // control
      impl_loc = a;
      return impl_loc;
    endfunction
  endclass

  // ---- constructor with NO body locals: the byte-identity cell
  class c_bare;
    int m_b;
    function new(int v);
      m_b = v;
    endfunction
  endclass

  c_unit     h_unit;
  c_mod      h_mod;
  c_outer    h_outer;
  c_concrete h_conc;
  c_bare     h_bare;
  int        r;

  initial begin
    h_unit  = new(1);
    h_mod   = new(2);
    h_outer = new(3);
    h_conc  = new(4);
    h_bare  = new(5);
    r = h_unit.unit_meth(1) + h_mod.mod_meth(2) + h_conc.must_impl(3);
  end
endmodule
