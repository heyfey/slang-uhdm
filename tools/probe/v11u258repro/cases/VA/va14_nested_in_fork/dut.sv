// § cloneLoopVarAssocIdxTs258 (the foreach inside a fork and a nested begin in the extern method)
package p;
  typedef struct packed { bit [7:0] lo; bit [7:0] hi; } rng_t;
  class c;
    local int m[rng_t];
    extern task t();
  endclass
  task c::t(); c top; int n; top = this;
    fork
      begin begin foreach (top.m[r]) n += r.lo; end end
    join
  endtask
endpackage
package q; import p::*; endpackage
module top; import p::*; endmodule
