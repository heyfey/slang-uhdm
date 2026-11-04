// § cloneLoopVarAssocIdxTs258 (a packed union index typedef)
package p;
  typedef union packed { bit [15:0] w; bit [1:0][7:0] b; } u_t;
  class c;
    local int m[u_t];
    extern function int f();
  endclass
  function int c::f(); c top; int n; top = this;
    foreach (top.m[r]) n += r.w;
    return n;
  endfunction
endpackage
package q; import p::*; endpackage
module top; import p::*; endmodule
