// § clsInModTdLastWriter462
package p;
  typedef struct { int a; logic [3:0] b; } s_t;
endpackage
program pr;
  import p::*;
  class C;
    int k;
  endclass
  s_t v;
endprogram
module top;
  import p::*;
  s_t q;
endmodule
