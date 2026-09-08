// v209 verifier arm M — THE DYNAMIC CONTAINERS, hoisted, with lifetimes.
// emitPkgArrayVar's package-scope split (assoc marked, queue not) must stay
// for package items and must NOT be applied to a hoisted local — and a
// written `static` hoisted container must come back unmarked.
package pm209;
  int  pm_assoc[string];
  int  pm_q[$];
  int  pm_dyn[];
  class cm209;
    int q;
    extern function new();
  endclass
  function cm209::new();
    int        lm_assoc[string];
    int        lm_q[$];
    int        lm_dyn[];
    static int lm_assoc_s[string];
    static int lm_q_s[$];
    lm_q.push_back(1);
    q = 8;
  endfunction
endpackage

import pm209::*;

module gm209;
  initial $display("m");
endmodule
