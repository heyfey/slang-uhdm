// § cloneLoopVarAssocIdxTs258 (an index typed by a class type parameter specialized with a package struct)
package p;
  typedef struct packed { bit [7:0] lo; bit [7:0] hi; } rng_t;
  class c #(type K = int);
    local int m[K];
    extern function int f();
  endclass
  function int c::f(); c #(K) top; int n; top = this;
    foreach (top.m[r]) n++;
    return n;
  endfunction
  class d; c #(rng_t) h; endclass
endpackage
package q; import p::*; endpackage
module top; import p::*; endmodule
