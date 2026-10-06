// § cloneLoopVarAssocIdxTs258 (a struct index typedef declared inside the class)
package p;
  class c;
    typedef struct packed { bit [7:0] lo; bit [7:0] hi; } rng_t;
    local int m[rng_t];
    extern function int f();
  endclass
  function int c::f(); c top; int n; top = this;
    foreach (top.m[r]) n += r.lo;
    return n;
  endfunction
endpackage
package q; import p::*; endpackage
module top; import p::*; endmodule
