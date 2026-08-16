// VERIFIER arm — INHERITED class-scope enum constant, read UNQUALIFIED from an
// OUT-OF-BODY method of the DERIVED class.  classScopeEnumConst76's walk says
// true (the enum's scope walks out to base76's ClassType) and the ScopedName
// test does not fire, so the patch MINTS a wire.  Does golden?
package p76i;
  class base76;
    typedef enum {B_A, B_B} b76_t;
    b76_t bm;
  endclass
  class der76 extends base76;
    extern function int oobf(int k);
  endclass
  function int der76::oobf(int k);
    int r;
    r = 0;
    if (bm == B_A) r = r + 1;      // inherited enum const, UNQUALIFIED, OOB
    if (bm == B_B) r = r + 2;
    return r + k;
  endfunction
endpackage
import p76i::*;
module top76i;
  der76 d;
  int r;
  initial begin
    d = new();
    r = d.oobf(1);
  end
endmodule
