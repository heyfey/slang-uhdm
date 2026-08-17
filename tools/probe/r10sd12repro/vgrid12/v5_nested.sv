// vsd12 cell v5 — THE DECLARING CLASS IS NESTED.  vsd10's V-FIX rewrote
// r10sd10's REACH/ORDER terms precisely for this shape (`<outermost
// container>::<one segment>`), and this law hands the SAME terms an ELEMENT.
// Four rows, each with its scalar twin:
//
//   outer5::o_t  from a class nested IN outer5  — owner is the OUTERMOST class,
//       its key is a strict PREFIX, so it sorts first and RESOLVES
//   o_t          the same, spelled BARE
//   a5::a_t      a TOP-LEVEL EARLY sibling, named from inside a nested class —
//       the owner is NOT a direct child of the container the OUTERMOST class
//       sits in?  it IS (both live in pv5), so REACH holds and ORDER compares
//       against the OUTERMOST class's name `outer5`, not `inner5`
//   z5::z_t      a TOP-LEVEL LATE sibling, same question, other direction
package pv5;

  class zelv5;
    int q;
  endclass

  class a5;
    typedef zelv5 a_t;
  endclass

  class z5;
    typedef zelv5 z_t;
  endclass

  class outer5;
    typedef zelv5 o_t;
    class inner5;
      function void f5();
        outer5::o_t n_q[$];
        outer5::o_t n_s;
        o_t         b_q[$];
        o_t         b_s;
        a5::a_t     e_q[$];
        a5::a_t     e_s;
        z5::z_t     l_q[$];
        z5::z_t     l_s;
        n_q = {};
        b_q = {};
        e_q = {};
        l_q = {};
      endfunction
    endclass
  endclass

endpackage

module topv5;
  initial begin
    pv5::outer5::inner5 u = new();
    u.f5();
  end
endmodule
