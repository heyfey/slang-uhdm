// § cloneAggTsAtHomeListing241
package p;
  class qc;
    int v;
  endclass
  typedef enum { EA, EB } e_t;
  class fac;
    extern function void print();
  endclass
  function void fac::print();
    e_t k;
    e_t ks[$];
    int n;
    n = 0;
    k = EB;
    ks.push_back(k);
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
