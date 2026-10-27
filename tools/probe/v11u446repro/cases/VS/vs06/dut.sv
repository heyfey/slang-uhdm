// § aggCopyClassMemberHomeInst446
package p;
  class C #(int W = 4);
    bit [W-1:0] v;
  endclass
  typedef struct { C #(8) m; C n; } s_t;
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
