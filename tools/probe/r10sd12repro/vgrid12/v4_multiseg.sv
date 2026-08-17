// vsd12 cell v4 — MULTI-SEGMENT SPELLINGS.  r10sd10's `oneSeg` term rejects a
// written scope of TWO OR MORE segments, because Surelog's lookup rebuilds
// exactly ONE key.  At the SCALAR site that was measured (v12 `s_sib2`); at the
// ELEMENT site it is inherited and never measured, so it is measured here, in
// three flavours: cross-package, same-package, and a package-qualified class
// whose class is the DECLARING class's own outer container.
package qv4;
  class ao4;
    typedef int                      a_t;
    typedef struct packed { int f; } as_t;
  endclass
endpackage

package pv4;
  import qv4::*;

  class sib4;
    typedef int s_t;
  endclass

  class user4;
    function void f4();
      qv4::ao4::a_t  x_q[$];        // TWO segments, cross-package
      qv4::ao4::a_t  x_s;
      qv4::ao4::as_t x_fx[2];
      qv4::ao4::as_t x_ss;
      pv4::sib4::s_t y_q[$];        // TWO segments, SAME package
      pv4::sib4::s_t y_s;
      ao4::a_t       z_q[$];        // ONE segment, but an IMPORTED owner
      ao4::a_t       z_s;
      x_q = {};
      y_q = {};
      z_q = {};
    endfunction
  endclass

endpackage

module topv4;
  initial begin
    pv4::user4 u = new();
    u.f4();
  end
endmodule
