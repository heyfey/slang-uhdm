// VERIFIER arm — PARAMETERIZED class, out-of-body method, unqualified
// class-scope enum constant.  The specialization's parent scope is what
// classBodyHomePkg75 reads.
package p76g;
  class c76 #(int W = 4);
    typedef enum {P_A, P_B} p76_t;
    p76_t m;
    extern function int oobf(int k);
  endclass
  function int c76::oobf(int k);
    int r;
    r = 0;
    if (m == P_A) r = r + 1;
    return r + k + W;
  endfunction
endpackage
import p76g::*;
module top76g;
  c76 #(3) c;
  int r;
  initial begin c = new(); r = c.oobf(1); end
endmodule
