// § aggCopyClassMemberHomeInst446
package p;
  class C;
  endclass
  typedef struct { C m; int k; } s_t;
endpackage
package q;
  import p::*;
  typedef struct { s_t in; C c; } t_t;
  class D;
    t_t x;
    s_t y[2];
    s_t z[$];
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule
