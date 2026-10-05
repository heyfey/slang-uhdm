// § cloneLocalArrayTsParented241
package p;
  class qc;
    int v;
  endclass
  class fac;
    extern function void print();
  endclass
  function void fac::print();
    int fq[4];
    int n;
    n = 0;
    fq[0] = 1;
    n = fq[1];
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
