// § cloneLoopVarAssocIdxTs258 (an enum index typedef declared inside the class)
package p;
  class c;
    typedef enum {A, B, C} e_t;
    local int m[e_t];
    extern function int f();
  endclass
  function int c::f(); c top; int n; top = this;
    foreach (top.m[k]) n += int'(k);
    return n;
  endfunction
endpackage
package q; import p::*; endpackage
module top; import p::*; endmodule
