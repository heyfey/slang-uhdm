// § clsPropElemAliasName247
package p;
  typedef int my_t;
  typedef bit [3:0] v_t;
  class q;
    my_t m2[2][3];
    v_t dq[][$];
    static v_t sf[2];
    local my_t lq[$];
    rand v_t rq[4];
  endclass
endpackage
module top;
  import p::*;
  q x;
endmodule
