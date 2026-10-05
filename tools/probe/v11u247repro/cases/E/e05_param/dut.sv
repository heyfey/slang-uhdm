// § clsPropElemAliasName247
package p;
  typedef int my_t;
  typedef bit [7:0] v_t;
  class q #(int N = 2);
    my_t aq[$];
    v_t fa[N];
  endclass
endpackage
module top;
  import p::*;
  q x;
  q#(4) y;
endmodule
