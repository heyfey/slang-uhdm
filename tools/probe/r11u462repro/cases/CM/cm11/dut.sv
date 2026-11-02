// § clsInModTdLastWriter462
package p;
  typedef struct { int a; logic [3:0] b; } s_t;
endpackage
module m;
  import p::*;
  class C #(int W = 4);
    logic [W-1:0] k;
  endclass
  C #(8) h;
  s_t v;
endmodule
module top;
  m u();
endmodule
