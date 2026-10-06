// § cloneLoopVarAssocIdxTs258 (a parameterized class with a struct index, specialized in the importer module)
package p;
  typedef struct packed { bit [7:0] lo; bit [7:0] hi; } rng_t;
  class c #(int W = 4);
    local int m[rng_t];
    extern function int f();
  endclass
  function int c::f(); c #(W) top; int n; top = this;
    foreach (top.m[r]) n += r.lo + W;
    return n;
  endfunction
endpackage
package q; import p::*; endpackage
module top; import p::*; c #(8) h; endmodule
