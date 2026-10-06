// § cloneLoopVarAssocIdxTs258 (bare loop list over a struct-indexed associative property in a class method, wildcard-import copy)
package p;
  typedef struct packed {
    bit [7:0] lo;
    bit [7:0] hi;
  } rng_t;
  class c;
    int m[rng_t];
    function int f();
      int n;
      foreach (m[r])
        n += r.lo;
      return n;
    endfunction
  endclass
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
