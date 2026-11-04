// § clsInModTdLastWriter462
package p;
  typedef struct { int a; logic [3:0] b; } s_t;
endpackage
module m;
  import p::*;
  typedef struct { int x; } l_t;
  class C;
    int k;
  endclass
  s_t v;
  l_t w;
endmodule
module top;
  m u();
endmodule
