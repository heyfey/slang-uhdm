// § cloneLoopVarAssocIdxTs258 (a two-dimensional associative array, struct then string index, two loop variables)
package p;
  typedef struct packed { bit [7:0] lo; bit [7:0] hi; } rng_t;
  class c;
    local int m[rng_t][string];
    extern function int f();
  endclass
  function int c::f(); c top; int n; top = this;
    foreach (top.m[r, s]) n += r.lo + s.len();
    return n;
  endfunction
endpackage
package q; import p::*; endpackage
module top; import p::*; endmodule
