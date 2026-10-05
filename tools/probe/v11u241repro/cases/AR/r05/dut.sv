// § cloneLocalArrayTsParented241
package p;
  class qc; int v; endclass
  class fac;
    extern function void print();
  endclass
  function void fac::print();
    qc sq[$];
    qc am[string];
    sq.delete();
  endfunction
endpackage
package q;
  import p::*;
  class u; fac x; endclass
endpackage
module top;
  import q::*;
  u w;
endmodule
