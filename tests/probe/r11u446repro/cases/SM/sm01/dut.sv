// § aggCopyClassMemberHomeInst446
package p;
  class C;
  endclass
  typedef struct { C m; string n; } s_t;
endpackage
package q;
  import p::*;
  class D;
    s_t x;
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule
