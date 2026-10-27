// § clsTdQueueLocalCloneUnsupported446
package p;
  class F;
    typedef enum {E0, E1} k_t;
    extern function int look();
  endclass
  function int F::look();
    k_t ks[$];
    ks.push_back(E1);
    return ks.size();
  endfunction
endpackage
package q;
  import p::*;
  class D;
    F f;
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule
