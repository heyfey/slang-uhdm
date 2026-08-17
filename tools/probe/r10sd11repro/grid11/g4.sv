// r10sd11 grid cell g4 — THE SPELLING axis and the NEGATIVE controls.
//
//   * a BARE name reaching a class-nested typedef by INHERITANCE
//   * the declaring class's OWN typedef, written bare and written self-scoped
//   * a PACKAGE typedef of a class name, written `pkg::td` and written bare
//     — the control that says `::` alone is not the trigger
//   * an OUT-OF-BODY method body
package px4;
  // ORDERING NOTE.  slang refuses `Owner::td` when `Owner` is only
  // forward-declared, so every owner class is written BEFORE its user and the
  // USER class is written LAST.  That costs the cell nothing: Surelog's class
  // pass is LEXICOGRAPHIC (r10sd10 `g8`), and this law's claim order is read
  // off NAMES too, so `auser*` still sorts first and every `z*` owner still
  // sorts after it.

  class zelem4;
    int q;
  endclass

  class zbase4;
    typedef zelem4 c_t;          // typedef of a class NAME, in a class
    typedef struct { int a; } s_t;
  endclass

  typedef zelem4 pkg_c_t;        // the same shape, in the PACKAGE
  typedef struct { int a; } pkg_s_t;

  class aderiv4 extends zbase4;
    typedef zelem4 own_c_t;      // the declaring class's OWN typedef
    extern function void f_oob();
    function void f_inline();
      c_t        b_inh;          // BARE, inherited from zbase4
      zbase4::c_t b_scoped;      // SCOPED at the base
      own_c_t    b_own;          // BARE, own
      aderiv4::own_c_t b_ownq;   // SELF-QUALIFIED, own
      px4::pkg_c_t p_scoped;     // PACKAGE typedef, scoped  (control)
      pkg_c_t     p_bare;        // PACKAGE typedef, bare    (control)
      zbase4::s_t b_struct;      // struct declared in place (control)
      px4::pkg_s_t p_struct;     // package struct           (control)
    endfunction
  endclass

  function void aderiv4::f_oob();
    c_t        o_inh;
    zbase4::c_t o_scoped;
    own_c_t    o_own;
  endfunction

endpackage

module top4;
  initial begin
    px4::aderiv4 u = new();
    u.f_inline();
  end
endmodule
