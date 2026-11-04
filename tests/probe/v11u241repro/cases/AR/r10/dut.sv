// § cloneLocalArrayTsParented241
package p;
  class qc;
    int v;
  endclass
  class fac;
    extern function void print();
  endclass
  function void fac::print();
    qc sq[$];
    qc tq[$];
    int n;
    n = 0;
    sq.delete();
    tq = sq;
    n = tq.size();
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
package q2;
  import p::*;
  class u2;
    fac y;
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  fac z;
  u w;
  initial w = new();
endmodule
