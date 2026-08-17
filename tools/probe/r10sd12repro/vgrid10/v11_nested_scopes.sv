// vsd10 adversarial cell v11 — the NESTED-OWNER shape at every container scope,
// and at two levels of nesting.  An OUTER class's map key is a strict PREFIX of
// its INNER class's key, so the outer is ALWAYS compiled first.
package px11;
  class o11;
    typedef struct { int o; } o_t;
    class m11;
      typedef struct { int m; } m_t;
      class i11;
        typedef struct { int i; } i_t;
        function void f();
          o11::o_t      v_gp_scoped;   // GRANDPARENT, scoped
          o11::m11::m_t v_p_scoped;    // PARENT, fully scoped
          m_t           v_p_bare;      // PARENT, bare
          o_t           v_gp_bare;     // GRANDPARENT, bare
          i_t           v_self;        // control
          v_gp_scoped.o = 1; v_p_scoped.m = 2;
          v_p_bare.m = 3; v_gp_bare.o = 4; v_self.i = 5;
        endfunction
      endclass
    endclass
  endclass
endpackage

// the same nesting at $unit scope
class uo11;
  typedef struct { int o; } o_t;
  class ui11;
    function void f();
      uo11::o_t v_unit_outer_scoped;
      o_t       v_unit_outer_bare;
      v_unit_outer_scoped.o = 1;
      v_unit_outer_bare.o   = 2;
    endfunction
  endclass
endclass

// and inside a MODULE
module top11;
  class mo11;
    typedef struct { int o; } o_t;
    class mi11;
      function void f();
        mo11::o_t v_mod_outer_scoped;
        o_t       v_mod_outer_bare;
        v_mod_outer_scoped.o = 1;
        v_mod_outer_bare.o   = 2;
      endfunction
    endclass
  endclass
  px11::o11 u;
  initial u = new();
endmodule
