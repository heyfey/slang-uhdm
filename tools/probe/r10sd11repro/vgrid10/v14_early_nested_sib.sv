// vsd10 adversarial cell v14 — the same nested-sibling shape with the owner renamed so it sorts BEFORE the declaring class: the current predicate answers this cell by ORDER, so an EARLY-sorting nested sibling exposes what REACH alone would have refused.
// DECLARING CLASS'S OUTERMOST CONTAINER (its package/module) and nothing else?
// Three shapes that separate that model from "any enclosing class scope":
//   * a NESTED class's OWN typedef, self-qualified
//   * two SIBLING nested classes inside one outer class
//   * a TOP-LEVEL early-sorting sibling named from inside a NESTED class
package px14;

  class a14;
    typedef struct { int a; } a_t;
  endclass

  class o14;
    class b13;
      typedef struct { int n; } n_t;
    endclass
    class m14;
      typedef struct { int m; } m_t;
      function void f();
        m14::m_t s_nested_self;   // nested class's OWN typedef, self-qualified
        b13::n_t s_nested_sib;    // sibling NESTED class, one segment
        a14::a_t s_toplevel_sib;  // TOP-LEVEL early sibling, from a nested class
        s_nested_self.m = 1;
        s_nested_sib.n  = 2;
        s_toplevel_sib.a = 3;
      endfunction
    endclass
  endclass

endpackage

module top14;
  px14::o14 u;
  initial u = new();
endmodule
