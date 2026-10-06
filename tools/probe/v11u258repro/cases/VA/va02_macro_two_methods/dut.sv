// § cloneLoopVarAssocIdxTs258 (one macro body holding the foreach expanded in two extern methods over two struct-indexed arrays)
`define FE(M, F) foreach (top.M[r]) n += r.F;
package p;
  typedef struct packed { bit [7:0] lo; bit [7:0] hi; } rng_t;
  typedef struct packed { bit [3:0] a; bit [3:0] b; } r2_t;
  class c;
    local int m[rng_t];
    local int k[r2_t];
    extern function int f();
    extern function int g();
  endclass
  function int c::f(); c top; int n; top = this; `FE(m, lo) return n; endfunction
  function int c::g(); c top; int n; top = this; `FE(k, a) return n; endfunction
endpackage
package q; import p::*; endpackage
module top; import p::*; endmodule
