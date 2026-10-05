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
      string q[5];
      int m;
      q[0] = "a"; m = q[0].len(); r = m;
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
