// § clsInModTdLastWriter462
package p;
  typedef struct { int a; logic [3:0] b; } s_t;
endpackage
module m;
  import p::*;
  class C;
    int k;
  endclass
  s_t v;
endmodule
module z_top;
  m u();
endmodule
