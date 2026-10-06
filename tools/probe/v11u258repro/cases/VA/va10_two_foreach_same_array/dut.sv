// § cloneLoopVarAssocIdxTs258 (two foreach statements over the same struct-indexed array in one method)
package p;
  typedef struct packed { bit [7:0] lo; bit [7:0] hi; } rng_t;
  class c;
    local int m[rng_t];
    extern function int f();
  endclass
  function int c::f(); c top; int n; top = this;
    foreach (top.m[r]) n += r.lo;
    foreach (top.m[r]) n -= r.hi;
    return n;
  endfunction
endpackage
package q; import p::*; endpackage
module top; import p::*; endmodule
