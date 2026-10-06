// § cloneLoopVarAssocIdxTs258 (a struct-indexed array reached through a handle argument, not this)
package p;
  typedef struct packed { bit [7:0] lo; bit [7:0] hi; } rng_t;
  class c;
    int m[rng_t];
    extern static function int f(c h);
  endclass
  function int c::f(c h); int n;
    foreach (h.m[r]) n += r.hi;
    return n;
  endfunction
endpackage
package q; import p::*; endpackage
module top; import p::*; endmodule
