// r10v178 VERIFIER ARM E — CONTROL DEPTH 0..3 x CLONE, and the NESTED RETURN.
// MEASUREMENT ONLY.  Depth is the uvm site's own dimension (`for`/`for`/`if`).
// The nested-return cells matter because § 169's fold window only reaches a
// return that is a DIRECT statement of the body: a return under an `if` is a
// different cell and the law's term-3 must not confuse the two.

package Depth_home_V;
  parameter int DK_V = 32'h0f0f_1234;

  function automatic int d0_v(input int a);                       // depth 0
    int r; r = a; r ^= DK_V; return r;
  endfunction
  function automatic int d1_v(input int a);                       // depth 1
    int r; r = a; if (a[0]) r ^= DK_V; return r;
  endfunction
  function automatic int d2_v(input int a);                       // depth 2
    int r; r = a;
    for (int i = 0; i < 4; i++) if (a[i]) r ^= DK_V;
    return r;
  endfunction
  function automatic int d3_v(input int a);                       // depth 3
    int r; r = a;
    for (int i = 0; i < 4; i++)
      for (int j = 0; j < 8; j++)
        if (a[j]) begin r ^= DK_V; end
    return r;
  endfunction
  function automatic int dret_top_v(input int a);                 // DIRECT return
    return DK_V;
  endfunction
  function automatic int dret_nest_v(input int a);                // NESTED return
    if (a[0]) return DK_V;
    return 0;
  endfunction
  function automatic int dret_nestop_v(input int a);              // NESTED return, op
    if (a[1]) return a + DK_V;
    return 1;
  endfunction
  function automatic int dret_topop_v(input int a);               // DIRECT return, op
    return a + DK_V;
  endfunction
  function automatic int dret_topsys_v(input int a);              // DIRECT return, $sys
    return $clog2(DK_V) + a;
  endfunction
endpackage

package Depth_imp_V;
  import Depth_home_V::*;
endpackage

module m_v178e (input logic ck, output int e1);
  import Depth_home_V::*;
  import Depth_imp_V::*;
  assign e1 = d0_v(1) + d1_v(2) + d2_v(3) + d3_v(4)
            + dret_top_v(5) + dret_nest_v(6) + dret_nestop_v(7)
            + dret_topop_v(8) + dret_topsys_v(9);
endmodule
