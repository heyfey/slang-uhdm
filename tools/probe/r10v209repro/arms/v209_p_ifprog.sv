// v209 verifier arm P — THE SAME MATERIALISED IMPORT INSIDE AN INTERFACE AND A
// PROGRAM.  `collectImportedPkgVars` runs for every InstanceBody, not just a
// module, so the law's gate has to give the same value in all three.
package pp209;
  class cp209a;
    int n;
  endclass
  cp209a pp_own;
  int    pp_int;
  class cp209b;
    int q;
    extern function new();
  endclass
  function cp209b::new();
    cp209a        lp_h;
    static cp209a lp_h_static;
    int           lp_i;
    lp_h = null;
    lp_h_static = null;
    q = 11;
  endfunction
endpackage

interface ip209;
  import pp209::*;
  logic iw;
endinterface

program pr209;
  import pp209::*;
  initial $display("p");
endprogram

module gp209;
  import pp209::*;
  ip209 u_if();
  initial $display("gp");
endmodule
