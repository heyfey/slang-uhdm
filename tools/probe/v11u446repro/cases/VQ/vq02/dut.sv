// § clsTdQueueLocalCloneUnsupported446
package p;
  class F;
    typedef int unsigned u_t;
    typedef bit [7:0] b_t;
    extern function int look();
  endclass
  function int F::look();
    u_t a[];
    b_t b[$];
    a = new[2];
    return a.size() + b.size();
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
