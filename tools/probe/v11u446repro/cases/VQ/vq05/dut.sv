// § clsTdQueueLocalCloneUnsupported446
package p;
  class F;
    typedef struct { int a; } al_t;
    function int inl();
      al_t hits[$];
      return hits.size();
    endfunction
    extern function int look();
  endclass
  function int F::look();
    al_t hits[string];
    al_t q2[$:4];
    return hits.size() + q2.size();
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
