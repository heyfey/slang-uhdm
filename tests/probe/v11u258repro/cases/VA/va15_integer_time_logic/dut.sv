// § cloneLoopVarAssocIdxTs258 (integer, time, single bit and untypedef'd logic-vector indices)
package p;
  class c;
    local int a[integer];
    local int t[time];
    local int b[bit];
    local int l[logic [3:0]];
    extern function int f();
  endclass
  function int c::f(); c top; int n; top = this;
    foreach (top.a[i]) n += i;
    foreach (top.t[k]) n += int'(k);
    foreach (top.b[j]) n += j;
    foreach (top.l[x]) n += x;
    return n;
  endfunction
endpackage
package q; import p::*; endpackage
module top; import p::*; endmodule
