// § cloneLoopVarAssocIdxTs258 (an extern task, not a function)
package p;
  typedef struct packed { bit [7:0] lo; bit [7:0] hi; } rng_t;
  class c;
    local int m[rng_t];
    extern task t(output int n);
  endclass
  task c::t(output int n); c top; top = this; n = 0;
    foreach (top.m[r]) n += r.lo;
  endtask
endpackage
package q; import p::*; endpackage
module top; import p::*; endmodule
