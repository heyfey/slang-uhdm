// r10v178 VERIFIER ARM G — TRANSITIVE / DIAMOND CLONES and the OUT-OF-BODY
// half reading a THIRD package's parameter.  MEASUREMENT ONLY.
//   Root_G  : the parameter's home, with a free function and an out-of-body
//             class method that both read it.
//   Mid1_G  : wildcard-imports Root_G          (clone group 1)
//   Mid2_G  : wildcard-imports Root_G too      (clone group 2, the SAME home
//             cloned into two different importers)
//   Leaf_G  : wildcard-imports BOTH Mid1_G and Mid2_G — a DIAMOND, so it
//             carries clones of clones.
//   Third_G : a package whose own function and out-of-body method read
//             Root_G's parameter through a wildcard import; when Third_G is
//             itself cloned into Cl3_G the clone body's parameter home
//             (Root_G) is NOT the cloned package (Third_G), which is the
//             gate's term-2 refusal, measured on the CLASS half too.

package Root_G;
  parameter int ROOT_K_G = 32'h7788_99aa;
  class RC_G;
    extern function int rc_read(input int a);
  endclass
  function int RC_G::rc_read(input int a);
    int r; r = a; r ^= ROOT_K_G; return r;
  endfunction
  function automatic int root_free(input int a);
    int r; r = a; r ^= ROOT_K_G; return r;
  endfunction
endpackage

package Mid1_G;  import Root_G::*;  endpackage
package Mid2_G;  import Root_G::*;  endpackage
package Leaf_G;  import Mid1_G::*;  import Mid2_G::*;  endpackage

package Third_G;
  import Root_G::*;
  class TC_G;
    extern function int tc_read(input int a);
  endclass
  function int TC_G::tc_read(input int a);
    int r; r = a; r ^= ROOT_K_G; return r;     // a THIRD package's parameter
  endfunction
  function automatic int third_free(input int a);
    int r; r = a; r ^= ROOT_K_G; return r;     // a THIRD package's parameter
  endfunction
endpackage

package Cl3_G;  import Third_G::*;  endpackage

module m_v178g (input logic ck, output int g1, g2, g3, g4);
  import Root_G::*;
  import Mid1_G::*;
  import Leaf_G::*;
  import Third_G::*;
  import Cl3_G::*;
  RC_G rc = new();
  TC_G tc = new();
  assign g1 = root_free(1);
  assign g2 = third_free(2);
  int t3, t4;
  assign g3 = t3;
  assign g4 = t4;
  always_comb begin
    t3 = rc.rc_read(3);
    t4 = tc.tc_read(4);
  end
endmodule
