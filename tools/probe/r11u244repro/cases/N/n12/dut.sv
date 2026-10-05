// § cloneBlockFixedArrTsParented244
package p;
  typedef struct { int a; } s_t;
  class h; int v; endclass
  class fac;
    extern function int emit();

  endclass
  function int fac::emit();
    int r;
    r = 0;
    begin
      int q[5];
      int m;
      foreach (q[i]) q[i] = i; m = q[$size(q)-1]; r = m;
    end
    return r;
  endfunction
endpackage
package q;
  import p::*;
  class u;
    function void f();
      fac x;
      x = null;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  fac z;
  u w;
  initial w = new();
endmodule
