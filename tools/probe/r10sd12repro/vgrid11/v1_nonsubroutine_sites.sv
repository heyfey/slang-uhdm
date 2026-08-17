// vsd11 v1 — THE SITES THE LAW MUST NOT TOUCH.
// The patch installs its predicate at FIVE emit sites, two of which
// (makeQueueDynArrayVar / makeAssocArrayVar) are shared factories.  This cell
// puts the SAME degrading typedef at a CLASS PROPERTY, a MODULE variable and a
// PACKAGE variable, in every declarator form, so that if either factory is
// reached from a non-subroutine site the boundary shows it.
package pv1;

  class zel1;
    int q;
  endclass

  class zk1;
    int q;
  endclass

  typedef zel1 pk1_t;          // the PACKAGE claimant of zel1 -> z1::d_t degrades

  class z1;
    typedef zel1 d_t;          // DEGRADES
    typedef zk1  k_t;          // CLAIMS (only typedef naming zk1)
  endclass

  // PACKAGE-level variables written with the degrading scoped typedef.
  z1::d_t pv_scalar;
  z1::d_t pv_aa[int];
  z1::d_t pv_q[$];
  z1::d_t pv_da[];
  z1::d_t pv_fx[4];

  class holder1;
    // CLASS PROPERTIES — a separate factory from every site the patch touches.
    z1::d_t m_scalar;
    z1::d_t m_aa[int];
    z1::d_t m_q[$];
    z1::d_t m_da[];
    z1::d_t m_fx[4];
    z1::k_t k_scalar;
    z1::k_t k_aa[int];
  endclass

endpackage

module topv1;
  import pv1::*;
  // MODULE variables — again a separate factory.
  z1::d_t mv_scalar;
  z1::d_t mv_aa[int];
  z1::d_t mv_q[$];
  z1::d_t mv_fx[4];
  initial begin
    holder1 h = new();
    h.m_aa[0] = null;
  end
endmodule
