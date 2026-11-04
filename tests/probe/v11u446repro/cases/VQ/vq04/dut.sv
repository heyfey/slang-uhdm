// § clsTdQueueLocalCloneUnsupported446
package p;
  class B;
    typedef struct { int a; } al_t;
  endclass
  class F extends B;
    extern function int look();
  endclass
  function int F::look();
    al_t hits[$];
    return hits.size();
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
