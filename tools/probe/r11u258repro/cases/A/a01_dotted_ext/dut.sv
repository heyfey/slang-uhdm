// § cloneLoopVarAssocIdxTs258 (dotted loop list over a struct-indexed associative property, out-of-body method, wildcard-import copy: uvm_reg_map's shape)
package p;
  typedef bit unsigned [63:0] addr_t;
  typedef struct packed {
    addr_t min;
    addr_t max;
    int unsigned stride;
  } rng_t;
  class c;
    local int m[rng_t];
    extern function void f(addr_t a);
  endclass
  function void c::f(addr_t a);
    c top;
    top = this;
    foreach (top.m[range]) begin
      if (a >= range.min && a <= range.max)
        a = 0;
    end
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
