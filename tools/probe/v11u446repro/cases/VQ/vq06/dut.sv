// § clsTdQueueLocalCloneUnsupported446
package p;
  typedef struct { int a; } pk_t;
  class F;
    typedef pk_t al_t;
    extern task look();
  endclass
  task F::look();
    al_t hits[$];
    pk_t raw[$];
    hits.push_back(raw[0]);
  endtask
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
