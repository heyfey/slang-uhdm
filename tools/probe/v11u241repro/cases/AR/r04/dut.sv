// § cloneLocalArrayTsParented241
package p;
  class qc; int v; endclass
  class fac;
    qc home[$];
    function void print();
      qc sq[$];
      foreach (sq[i]) sq[i] = null;
      foreach (home[j]) home[j] = null;
    endfunction
  endclass
endpackage
package q;
  import p::*;
  class u; fac x; endclass
endpackage
module top;
  import p::*;
  import q::*;
  fac z; u w;
endmodule
