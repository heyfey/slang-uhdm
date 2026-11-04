// § cloneLoopVarAssocIdxTs258 (a longint unsigned typedef index and a shortint index)
package p;
  typedef longint unsigned a_t;
  class c;
    local int m[a_t];
    local int s[shortint];
    extern function int f();
  endclass
  function int c::f(); c top; int n; top = this;
    foreach (top.m[r]) n += int'(r);
    foreach (top.s[k]) n += k;
    return n;
  endfunction
endpackage
package q; import p::*; endpackage
module top; import p::*; endmodule
