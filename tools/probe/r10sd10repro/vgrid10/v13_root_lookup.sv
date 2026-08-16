// vsd10 adversarial cell v13 — is the written scope resolved against the
// DECLARING CLASS'S OUTERMOST CONTAINER (its package/module) and nothing else?
// Three shapes that separate that model from "any enclosing class scope":
//   * a NESTED class's OWN typedef, self-qualified
//   * two SIBLING nested classes inside one outer class
//   * a TOP-LEVEL early-sorting sibling named from inside a NESTED class
package px13;

  class a13;
    typedef struct { int a; } a_t;
  endclass

  class o13;
    class n13;
      typedef struct { int n; } n_t;
    endclass
    class m13;
      typedef struct { int m; } m_t;
      function void f();
        m13::m_t s_nested_self;   // nested class's OWN typedef, self-qualified
        n13::n_t s_nested_sib;    // sibling NESTED class, one segment
        a13::a_t s_toplevel_sib;  // TOP-LEVEL early sibling, from a nested class
        s_nested_self.m = 1;
        s_nested_sib.n  = 2;
        s_toplevel_sib.a = 3;
      endfunction
    endclass
  endclass

endpackage

module top13;
  px13::o13 u;
  initial u = new();
endmodule
