// § cloneLoopVarAssocIdxTs258 (a queue of structs: the index is an int, the law must not fire)
package p;
  typedef bit unsigned [63:0] addr_t;
  typedef struct packed {
    addr_t min;
    addr_t max;
    int unsigned stride;
  } rng_t;
  class c;
    rng_t m[$];
    extern function int f(addr_t a);
  endclass
  function int c::f(addr_t a);
    c top;
    int n;
    top = this;
    foreach (m[range]) begin
      if (a >= m[range].min)
        n++;
    end
    return n;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;

endmodule
