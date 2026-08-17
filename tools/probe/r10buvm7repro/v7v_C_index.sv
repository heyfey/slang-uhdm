// vbuvm7 adversarial arm C — INDEX EXPRESSION exotica.
package pkC; parameter int K = 1; endpackage
typedef struct { int used; } stC_t;
function automatic int fidx(int a); return a; endfunction
class holdC;
  stC_t q[$];
  stC_t am[string];
  stC_t ai[4];
  stC_t a2[2][2];
  int   bi[4];
  function void f();
    int i; i = 0;
    q.push_back('{used:0});
    q[$].used++;                // C1 queue LAST index  q[$]
    am["k"].used++;             // C2 assoc string key (control, same as a5)
    ai[fidx(1)].used++;         // C3 index is a FUNCTION CALL
    ai[pkC::K].used++;          // C4 index is a PACKAGE-SCOPED constant
    ai[bi[i]].used++;           // C5 index is a NESTED SELECT
    ai[i+1].used++;             // C6 index is an expression
    a2[i][i+1].used++;          // C7 two dims, both expressions
    ai[i>0 ? 1 : 2].used++;     // C8 index is a ternary
  endfunction
endclass
module topC; initial begin end endmodule
