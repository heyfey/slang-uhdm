// § aggCopyClassMemberHomeInst446
package p;
  class C;
  endclass
  typedef C c_t;
  typedef struct { c_t m; int n; } s_t;
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
