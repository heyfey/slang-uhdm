// § clsInModTdLastWriter462
package p;
  typedef struct { int a; logic [3:0] b; } s_t;
  typedef enum { A, B } e_t;
endpackage
module m;
  import p::*;
  class C;
    int k;
  endclass
  s_t v;
  e_t e;
endmodule
module top;
  m u();
endmodule
