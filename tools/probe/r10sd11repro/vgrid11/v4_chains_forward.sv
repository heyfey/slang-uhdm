// vsd11 v4 — TYPEDEF-OF-TYPEDEF CHAINS and FORWARD typedefs.
// `tdSlot11` hops up to 16 alias links and peels declarator containers.  This
// cell builds a 3-deep chain, a chain that crosses a CLASS boundary, a typedef
// of a FORWARD-declared class, and a typedef whose target is a typedef of an
// ARRAY, and reads each one at the subroutine-local site.
package pv4;

  typedef class fwd4;          // FORWARD declaration

  class zel4;
    int q;
  endclass

  class za4;                   // sorts FIRST among the package's classes
    typedef zel4 a1_t;         // CLAIMS zel4 (4, "pv4::za4", "a1_t")
    typedef a1_t a2_t;         // same slot, loses
    typedef a2_t a3_t;         // same slot, loses
  endclass

  class zb4;
    typedef zel4 b1_t;         // loses to za4::a1_t
    typedef za4::a1_t b2_t;    // chain crossing a class boundary, loses
    typedef fwd4 f_t;          // target is the FORWARD-declared class
    typedef zel4 arr_t[$];     // declarator container peeled -> zel4, loses
    typedef arr_t arr2_t;      // chain over an array typedef
  endclass

  class fwd4;
    int z;
  endclass

  class user4;
    function void f4();
      za4::a1_t  v_a1;         // claimant  -> resolves
      za4::a2_t  v_a2;         // loser
      za4::a3_t  v_a3;         // loser
      zb4::b1_t  v_b1;         // loser
      zb4::b2_t  v_b2;         // loser
      zb4::f_t   v_f;          // only typedef naming fwd4 -> claims
      zb4::arr_t v_arr;
      zb4::arr2_t v_arr2;
      v_a1 = null;
      v_f = null;
    endfunction
  endclass

endpackage

module topv4;
  initial begin
    pv4::user4 u = new();
    u.f4();
  end
endmodule
