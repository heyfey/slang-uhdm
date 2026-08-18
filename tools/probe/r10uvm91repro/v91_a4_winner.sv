// v91 arm 4 — WHICH TYPEDEF NAMES THE SHARED OBJECT?
// H1 = the LAST PARAMETER of the chain with a candidate typedef (r10uvm91's law)
// H2 = the ALPHABETICALLY LAST typedef name (byte-wise)
// H4 = the SOURCE-LAST declared candidate typedef
// UVM cannot separate these; every cell below can.
package pv4;
  // d1: z_t on A (decl 1st), a_t on C (decl 2nd)   H1=a_t H2=z_t H4=a_t
  class d1 #(type A=int, type B=A, type C=B);
    typedef A z_t; typedef C a_t; A p_a; C p_c;
  endclass
  // d2: z_t on C (decl 1st), a_t on A (decl 2nd)   H1=z_t H2=z_t H4=a_t
  class d2 #(type A=int, type B=A, type C=B);
    typedef C z_t; typedef A a_t; A p_a; C p_c;
  endclass
  // d3: a_t on A (decl 1st), z_t on C (decl 2nd)   H1=z_t H2=z_t H4=z_t
  class d3 #(type A=int, type B=A, type C=B);
    typedef A a_t; typedef C z_t; A p_a; C p_c;
  endclass
  // d4: m_t on A, z_t on B, a_t on C               H1=a_t H2=z_t H4=a_t
  class d4 #(type A=int, type B=A, type C=B);
    typedef A m_t; typedef B z_t; typedef C a_t; A p_a; B p_b; C p_c;
  endclass
  // d5: b_t on A, a_t on B, none on C              H1=a_t H2=b_t H4=a_t
  class d5 #(type A=int, type B=A, type C=B);
    typedef A b_t; typedef B a_t; A p_a; B p_b; C p_c;
  endclass
  // d6: COLLATION — 'B_t' (0x42) vs 'a_t' (0x61).  Byte-wise: B_t < a_t.
  //     H1=B_t (C is last param) ; H2=a_t (a_t sorts after B_t)
  class d6 #(type A=int, type B=A, type C=B);
    typedef A a_t; typedef C B_t; A p_a; C p_c;
  endclass
  // d7: DIGITS — 't10' vs 't2'.  Byte-wise 't10' < 't2'.
  //     H1=t10 (on C) ; H2=t2 (on A)
  class d7 #(type A=int, type B=A, type C=B);
    typedef A t2; typedef C t10; A p_a; C p_c;
  endclass
  // d8: the same shape but on a TWO-parameter chain, to rule out chain length
  class d8 #(type A=int, type B=A);
    typedef A z_t; typedef B a_t; A p_a; B p_b;
  endclass
  // d9: THREE independent roots, each with one typedef -> three objects,
  //     each named by its own group only (no cross-group winner leakage)
  class d9 #(type A=int, type B=bit, type C=real);
    typedef A z_t; typedef B a_t; typedef C m_t; A p_a; B p_b; C p_c;
  endclass
endpackage
module topv4;
  import pv4::*;
  d1 u1; d2 u2; d3 u3; d4 u4; d5 u5; d6 u6; d7 u7; d8 u8; d9 u9;
endmodule
