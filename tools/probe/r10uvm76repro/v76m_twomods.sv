// VERIFIER arm — TWO modules both hoist the same package.  classPropRefs is a
// shared vector and bindHoistedClassPropRefs runs per module: whose wire does
// the reference finally bind, and does each module mint its own?
package p76m;
  class c76;
    typedef enum {M_A, M_B} m76_t;
    m76_t m;
    extern function int oobf(int k);
  endclass
  function int c76::oobf(int k);
    int r;
    r = 0;
    if (m == M_A) r = r + 1;
    return r + k;
  endfunction
endpackage
import p76m::*;
module aa76;
  c76 c;
  int r;
  initial begin c = new(); r = c.oobf(1); end
endmodule
module bb76;
  c76 c;
  int r;
  initial begin c = new(); r = c.oobf(2); end
endmodule
