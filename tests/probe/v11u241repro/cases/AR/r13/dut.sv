// § cloneLocalArrayTsParented241
package p;
  class qc;
    int v;
  endclass
  typedef struct { int a; int b; } s_t;
  class fac;
    extern function void print();
  endclass
  function void fac::print();
    s_t sq[$];
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
  import q::*;
  p::fac z;
  u w;
  initial w = new();
endmodule
