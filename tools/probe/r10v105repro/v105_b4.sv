// r10v105 arm b4 — the type parameter USED (not just declared): a cast, $cast,
// new(), a static method, a constraint, a covergroup, an argument, and a
// nested type reference `T::inner_t`.  MEASUREMENT ONLY.
package pu_b4;

  class du_b4;
    typedef int inner_t;
    rand int ux;
    function new(); ux = 0; endfunction
  endclass
  class eu_b4 extends du_b4;
    function new(); super.new(); endfunction
  endclass

  class cu_b4 #(type UT = du_b4);
    rand int rnd_b4;
    extern function void um();
    extern static function void sm();
    extern function UT retm();
    extern function void argm(input UT a);
    constraint cst_b4 { rnd_b4 > 0; }
    covergroup cg_b4;
      cp_b4 : coverpoint rnd_b4;
    endgroup
    function new(); cg_b4 = new(); endfunction
  endclass

  function void cu_b4::um();
    UT           xo_u;             // the plain local -> the law
    UT::inner_t  xo_nested;        // a NESTED type reference through T
    int          xo_i;
    xo_u = new();                  // new() on the parameter-typed local
    xo_i = int'(1);
    if (!$cast(xo_u, xo_u)) xo_i = 2;
  endfunction

  function void cu_b4::sm();
    UT xo_st;                      // a STATIC out-of-body method
  endfunction

  function cu_b4::UT cu_b4::retm();
    UT xo_r;
    xo_r = new();
    return xo_r;
  endfunction

  function void cu_b4::argm(input UT a);
    UT xo_a;
    xo_a = a;
  endfunction
endpackage

module topb4;
  import pu_b4::*;
  cu_b4            h_d;
  cu_b4 #(eu_b4)   h_e;
  initial begin h_d = new(); h_e = new(); end
endmodule
