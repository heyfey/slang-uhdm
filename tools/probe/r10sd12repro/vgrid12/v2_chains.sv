// vsd12 cell v2 — TYPEDEF CHAINS.  The peel returns the DECLARED element type,
// which for an alias-of-an-alias is the OUTER alias, and r10sd10's OWNER term
// then reads THAT alias's home scope.  So a chain can put the spelled name and
// the resolved owner in DIFFERENT classes, which no grid12 cell does:
//
//   z2::mid_t   — spelled scoped at z2, and mid_t LIVES in z2       (agree)
//   a2::imp_t   — spelled scoped at a2, imp_t lives in a2 but its
//                 TARGET is z2's alias                              (owner=a2)
//   own_t       — spelled BARE, lives in the declaring class, target
//                 is a scoped alias of a LATE class                 (owner=self)
//
// The law's claim is "the element is the scalar", so every row here must have
// the SAME class as the scalar twin declared beside it.
package pv2;

  class zelv2;
    int q;
  endclass

  class a2;                       // sorts BEFORE user2
    typedef zelv2 a_t;
  endclass

  class z2;                       // sorts AFTER user2
    typedef zelv2  base_t;
    typedef base_t mid_t;         // ALIAS OF AN ALIAS
  endclass

  class user2;
    typedef zelv2 own_t;
    function void f2();
      z2::mid_t  c_q[$];          // alias-of-alias in a LATE class
      z2::mid_t  c_s;             // the SCALAR twin
      a2::a_t    i_q[$];          // EARLY owner
      a2::a_t    i_s;             // the SCALAR twin
      own_t      o_q[$];          // BARE, own typedef, in-body
      own_t      o_s;             // the SCALAR twin
      c_q = {};
      i_q = {};
      o_q = {};
    endfunction
  endclass

endpackage

module topv2;
  initial begin
    pv2::user2 u = new();
    u.f2();
  end
endmodule
