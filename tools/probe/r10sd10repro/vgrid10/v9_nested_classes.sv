// vsd10 adversarial cell v9 — NESTED classes, BOTH directions.  The predicate
// treats "owner is not self and not a sibling" as NOT COMPILED, but an OUTER
// class's key is a strict PREFIX of its inner class's key, so the outer IS
// compiled first and Surelog can resolve its typedef from the inner body.
package px9;

  class outer9;
    typedef struct { int o; } o_t;

    class inner9;                       // key px9::outer9::inner9 > px9::outer9
      typedef struct { int i; } i_t;
      function void f();
        o_t          v_outer_bare;      // OUTER's typedef, bare, from INNER
        outer9::o_t  v_outer_scoped;    // ... and written SCOPED
        i_t          v_self_bare;       // control: own typedef
        v_outer_bare.o   = 1;
        v_outer_scoped.o = 2;
        v_self_bare.i    = 3;
      endfunction
    endclass

    // the reverse direction: OUTER using INNER's typedef (inner sorts AFTER)
    function void g();
      inner9::i_t v_inner_scoped;
      v_inner_scoped.i = 1;
    endfunction
  endclass

endpackage

module top9;
  px9::outer9 u;
  initial u = new();
endmodule
