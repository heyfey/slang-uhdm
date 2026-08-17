// vsd10 adversarial cell v12 — is the discriminator the number of SEGMENTS in
// the written scope, or the relation of the owner?  Measures, at package scope:
//   * an ANCESTOR named by ONE segment, at depth 1 and depth 2
//   * the SAME ancestor named by TWO segments
//   * a SIBLING named by TWO segments (pkg::cls::td) with the owner EARLY
package px12;

  class a12;                        // EARLY sibling
    typedef struct { int a; } a_t;
  endclass

  class o12;
    typedef struct { int o; } o_t;
    class m12;
      typedef struct { int m; } m_t;
      function void g();
        o12::o_t s_anc1_from_m;     // ancestor, ONE segment, depth 1
        s_anc1_from_m.o = 1;
      endfunction
      class i12;
        function void f();
          m12::m_t s_anc1_depth1;   // ancestor m12, ONE segment
          o12::o_t s_anc1_depth2;   // ancestor o12, ONE segment
          s_anc1_depth1.m = 1;
          s_anc1_depth2.o = 2;
        endfunction
      endclass
    endclass
  endclass

  class z12;
    function void f();
      px12::a12::a_t s_sib2;        // EARLY sibling, TWO segments
      a12::a_t       s_sib1;        // EARLY sibling, ONE segment (control)
      s_sib2.a = 1;
      s_sib1.a = 2;
    endfunction
  endclass

endpackage

module top12;
  px12::z12 u;
  initial u = new();
endmodule
