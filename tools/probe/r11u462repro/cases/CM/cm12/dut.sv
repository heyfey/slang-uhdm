// § clsInModTdLastWriter462
package p;
  typedef struct { int a; logic [3:0] b; } s_t;
  typedef enum bit [1:0] { A, B } e_t;
endpackage
module a_m;
  import p::*;
  class K;
    int k;
  endclass
  s_t v;
  e_t e;
endmodule
module m;
  import p::*;
  class C;
    int k;
  endclass
  s_t v;
  e_t e;
endmodule
module top;
  a_m x();
  m u();
endmodule
