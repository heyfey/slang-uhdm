// § clsPropElemAliasName247
package a;
  typedef int my_t;
  typedef bit [3:0] v_t;
endpackage
package p;
  class q;
    a::my_t aq[$];
    a::v_t vd[];
  endclass
endpackage
module top;
  import p::*;
  q x;
endmodule
