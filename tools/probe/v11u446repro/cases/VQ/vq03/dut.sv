// § clsTdQueueLocalCloneUnsupported446
package p;
  class F;
    typedef struct { int a; } al_t;
    extern function int look();
  endclass
  function int F::look();
    F::al_t hits[$];
    al_t one;
    hits.push_back(one);
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
