// § cloneLoopVarAssocIdxTs258 (the struct index typedef from a third package imported into the class package)
package p0; typedef struct packed { bit [7:0] lo; bit [7:0] hi; } rng_t; endpackage
package p;
  import p0::*;
  class c;
    local int m[rng_t];
    extern function int f();
  endclass
  function int c::f(); c top; int n; top = this;
    foreach (top.m[r]) n += r.hi;
    return n;
  endfunction
endpackage
package q; import p::*; endpackage
module top; import p::*; endmodule
