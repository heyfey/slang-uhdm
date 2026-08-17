// vsd12 cell v1 — PARAMETERIZED OWNER.  r10sd10's `oneSeg` term deliberately
// accepts a `ClassName` left segment (`aparm#(int)::td`) as ONE segment, and
// r10sd10's own grid measured that at the SCALAR site (cells v6/v2).  This law
// hands the SAME predicate an ELEMENT, so the parameterized-owner arm must be
// re-measured HERE: the peel produces the specialization's typedef and the
// spelling half still reads a ScopedName whose left is a ClassName.
//
// BOTH order directions, because the ORDER term compares leaf names:
//   aparm1 sorts BEFORE muser1  -> r10sd10 Resolved  (element must NOT move)
//   zparm1 sorts AFTER  muser1  -> r10sd10 ClassVar  (element becomes class_var)
package pv1;

  class zelv1;
    int q;
  endclass

  class aparm1 #(type T = int);
    typedef zelv1 p_t;
    typedef int   pi_t;
  endclass

  class zparm1 #(type T = int);
    typedef zelv1 z_t;
    typedef int   zi_t;
  endclass

  class muser1;
    function void f1();
      aparm1#(int)::p_t  a_q[$];      // EARLY parameterized owner
      aparm1#(int)::pi_t a_iq[$];
      aparm1#(int)::p_t  a_fx[2];
      zparm1#(int)::z_t  z_q[$];      // LATE parameterized owner
      zparm1#(int)::zi_t z_iq[int];
      zparm1#(int)::z_t  z_fx[2];
      a_q = {};
    endfunction
  endclass

endpackage

module topv1;
  initial begin
    pv1::muser1 u = new();
    u.f1();
  end
endmodule
