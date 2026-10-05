// § cloneLocalArrayTsParented241
package p;
  class qc;
    int v;
  endclass
  class fac;
    extern function void print();
  endclass
  function void fac::print();
    qc sq[string];
    int iq[int];
    qc dq[$];
    int n;
    n = 0;
    sq["a"] = null;
    n = sq.num();
  endfunction
endpackage
package q;
  import p::*;
  class u;
    fac x;
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  fac z;
  u w;
  initial w = new();
endmodule
