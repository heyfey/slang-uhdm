// § cloneLoopVarAssocIdxTs258 (a package function over a struct-indexed LOCAL associative array, wildcard-import copy)
package p;
  typedef struct packed {
    bit [7:0] lo;
    bit [7:0] hi;
  } rng_t;
  function automatic int f();
    int m[rng_t];
    int n;
    foreach (m[r])
      n += r.lo;
    return n;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
