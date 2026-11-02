// § clsInModTdLastWriter462
package p;
  typedef struct { int a; logic [3:0] b; } s_t;
  typedef enum { A, B } e_t;
endpackage
module m;
  import p::*;
  class C;
    s_t k;
  endclass
  C h;
endmodule
module top;
  import p::*;
  s_t w;
  m u();
endmodule
