// § clsPropElemAliasName247
package p;
  typedef int my_t;
  typedef my_t al_t;
  typedef bit [3:0] v_t;
  class q;
    al_t aq[$];
    v_t vq[$];
    v_t vq2[$];
    my_t s;
    my_t fa[3];
  endclass
endpackage
module top;
  import p::*;
  q x;
endmodule
