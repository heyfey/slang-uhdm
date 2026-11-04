// § cloneLoopVarAssocIdxTs258 (a struct index holding an enum member and a nested struct member, next to a wildcard-indexed array the loop does not visit)
package p;
  typedef enum logic [1:0] {R, W} k_t;
  typedef struct packed { bit [3:0] a; bit [3:0] b; } in_t;
  typedef struct packed { k_t kind; in_t inner; bit [7:0] lo; } rng_t;
  class c;
    local int w[*];
    local int m[rng_t];
    extern function int f();
  endclass
  function int c::f(); c top; int n; top = this;
    foreach (top.m[r]) n += r.lo + r.inner.a + int'(r.kind);
    return n;
  endfunction
endpackage
package q; import p::*; endpackage
module top; import p::*; endmodule
