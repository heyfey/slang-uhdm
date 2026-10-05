// § cloneBlockFixedArrTsParented244
package p;
  class fac;
    extern function int emit();
  endclass
  function int fac::emit();
    int r; int fq[5]; int fd[$];
    r = 0; fq[0] = 1; fd.push_back(2);
    begin
      int q[5];
      int m;
      q[0] = 1;
      m = q[0];
      r = m;
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
