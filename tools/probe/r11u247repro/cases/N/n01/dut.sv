// § clsPropElemAliasName247
package p;
  typedef int my_t;
  typedef bit [3:0] v_t;
  typedef byte b_t;
  class q;
    my_t tq[$];
    v_t vd[];
    b_t bf[2];
    my_t aa[string];
    int ia[my_t];
    my_t both[my_t];
  endclass
endpackage
module top;
  import p::*;
  q x;
endmodule
