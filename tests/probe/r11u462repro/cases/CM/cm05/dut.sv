// § clsInModTdLastWriter462
package p;
  typedef struct { int a; logic [3:0] b; } s_t;
endpackage
module m;
  import p::*;
  class B;
    int j;
  endclass
  class A;
    int k;
  endclass
  s_t v;
endmodule
module top;
  m u();
endmodule
