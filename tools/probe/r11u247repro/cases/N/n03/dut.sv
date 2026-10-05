// § clsPropElemAliasName247
package p;
  typedef int my_t;
  my_t pq[$];
  class q;
    function void f();
      my_t lq[$];
      lq.push_back(1);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  my_t mq[$];
  q x;
endmodule
