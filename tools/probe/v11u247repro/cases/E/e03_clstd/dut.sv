// § clsPropElemAliasName247
package p;
  class q;
    typedef int my_t;
    typedef enum {A, B} e_t;
    my_t aq[$];
    e_t ed[];
    static my_t st[2];
  endclass
  class r extends q;
    my_t rq[$];
  endclass
endpackage
module top;
  import p::*;
  r x;
endmodule
