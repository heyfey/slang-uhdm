// § cloneLoopVarAssocIdxTs258 (explicit-import copy of the class)
package p;
  typedef bit unsigned [63:0] addr_t;
  typedef struct packed {
    addr_t min;
    addr_t max;
    int unsigned stride;
  } rng_t;
  class c;
    local int m[rng_t];
    extern function int f(addr_t a);
  endclass
  function int c::f(addr_t a);
    c top;
    int n;
    top = this;
    foreach (top.m[range]) begin
      if (a >= range.min && a <= range.max)
        n++;
    end
    return n;
  endfunction
endpackage
package q;
  import p::c;
endpackage
module top;

endmodule
