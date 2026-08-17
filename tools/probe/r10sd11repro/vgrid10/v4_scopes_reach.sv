// vsd10 adversarial cell v4 — every SCOPE a class-nested typedef can be reached
// FROM: another package (import + explicit), $unit, a module body function, a
// package-scope function, and an inherited base in the SAME package.
package base4;
  class zbase4;
    typedef struct { int a; } b_t;
    typedef int bq_t[$];
  endclass
endpackage

// a $unit-level class
class zunit4;
  typedef struct { int u; } u_t;
endclass

class aunit4;
  function void f();
    zunit4::u_t v_unit_sibling;      // $unit sibling, scoped
    v_unit_sibling.u = 1;
  endfunction
endclass

package px4;
  import base4::*;

  class zsame4;
    typedef struct { int s; } s_t;
  endclass

  class auser4 extends base4::zbase4;
    function void f();
      base4::zbase4::b_t v_imported;   // owner in ANOTHER package
      b_t                v_inh_bare;   // inherited bare
      zsame4::s_t        v_sib;        // sibling, late-sorting
      v_imported.a = 1;
      v_inh_bare.a = 2;
      v_sib.s = 3;
    endfunction
  endclass

  // PACKAGE-scope function (no enclosing class at all)
  function automatic void pkgf4();
    zsame4::s_t p_local;
    p_local.s = 1;
  endfunction
endpackage

module top4;
  import px4::*;
  px4::auser4 u;
  aunit4      w;

  // MODULE-scope function local of a class-nested typedef
  function automatic void modf4();
    px4::zsame4::s_t m_local;
    m_local.s = 1;
  endfunction

  initial begin
    u = new();
    w = new();
    modf4();
    px4::pkgf4();
  end
endmodule
