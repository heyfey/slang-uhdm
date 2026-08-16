// VERIFIER arm — the enum constant read from a DEFAULT ARGUMENT and from a
// body-local DECLARATION INITIALIZER of an out-of-body method, not from a
// statement.  Both are emitted with inClassBodyEmit true.
package p76v;
  class c76;
    typedef enum {V_A, V_B, V_C} v76_t;
    v76_t m;
    extern function int oobf(v76_t k = V_A);
  endclass
  function int c76::oobf(v76_t k = V_A);
    v76_t loc = V_B;
    int r;
    r = (k == loc) ? 1 : 0;
    if (m == V_C) r = r + 2;
    return r;
  endfunction
endpackage
import p76v::*;
module top76v;
  c76 c;
  int r;
  initial begin c = new(); r = c.oobf(); end
endmodule
