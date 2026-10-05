// § cloneLocalArrayTsParented241
package p;
  class qc;
    int v;
  endclass
  class fac;
    extern function void print();
  endclass
  function void fac::print();
    string sq[$];
    int n;
    n = 0;
    sq.delete();
    n = sq.size();
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
