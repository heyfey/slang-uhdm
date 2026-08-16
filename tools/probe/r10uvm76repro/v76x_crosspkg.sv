// VERIFIER arm — the enum constant's own class lives in package q76x; the
// OUT-OF-BODY method that reads it unqualified lives in package p76x.  The
// site records classBodyHomePkg75 (the BODY's package, p76x), not the enum's
// own package (q76x); the module imports BOTH.  Which package must be
// materialized for the wire to appear, and does golden mint it at all?
package q76x;
  class base76;
    typedef enum {X_A, X_B} x76_t;
    x76_t bm;
  endclass
endpackage
package p76x;
  import q76x::*;
  class der76 extends base76;
    extern function int oobf(int k);
  endclass
  function int der76::oobf(int k);
    int r;
    r = 0;
    if (bm == X_A) r = r + 1;
    return r + k;
  endfunction
endpackage
import p76x::*;
module top76x;
  der76 d;
  int r;
  initial begin d = new(); r = d.oobf(1); end
endmodule
