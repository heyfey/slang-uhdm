// § clsInModTdLastWriter462
package p;
  typedef struct { int a; logic [3:0] b; } s_t;
endpackage
module m;
  import p::*;
  class C;
    s_t f;
  endclass
endmodule
module n;
  import p::*;
  s_t w;
endmodule
module top;
  m u();
  n v();
endmodule
