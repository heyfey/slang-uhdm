// § cloneLoopVarAssocIdxTs258 (two importer packages and a module importer, the module last)
package p;
  typedef struct packed { bit [7:0] lo; bit [7:0] hi; } rng_t;
  class c;
    local int m[rng_t];
    extern function int f();
  endclass
  function int c::f(); c top; int n; top = this;
    foreach (top.m[r]) n += r.lo;
    return n;
  endfunction
endpackage
package q1; import p::*; endpackage
package q2; import p::*; endpackage
module top; import p::*; endmodule
